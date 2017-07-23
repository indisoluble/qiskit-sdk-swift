//
//  SimulatorTools.swift
//  qiskit
//
//  Created by Manoel Marques on 7/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Contains functions used by the simulators.

 Author: Jay Gambetta and John Smolin

 Functions
 index2 -- Takes a bitstring k and inserts bits b1 as the i1th bit
 and b2 as the i2th bit

 enlarge_single_opt(opt, qubit, number_of_qubits) -- takes a single qubit
 operator opt to a opterator on n qubits

 enlarge_two_opt(opt, q0, q1, number_of_qubits) -- takes a two-qubit
 operator opt to a opterator on n qubits

 */
final class SimulatorTools {

    private init() {
    }

    /**
     Magic index1 function.

     Takes a bitstring k and inserts bit b as the ith bit,
     shifting bits >= i over to make room.
    */
    static func index1(_ b: Int, _ i: Int, _ k: Int) -> Int {
        var retval = k
        let lowbits = k & ((1 << i) - 1)  // get the low i bits

        retval >>= i
        retval <<= 1

        retval |= b

        retval <<= i
        retval |= lowbits

        return retval
    }

    /**
     Magic index2 function.

     Takes a bitstring k and inserts bits b1 as the i1th bit
     and b2 as the i2th bit
     */
    static func index2(_ b1: Int, _ i1: Int, _ b2: Int, _ i2: Int, _ k: Int) -> Int {
        assert(i1 != i2)
        var retval: Int = 0
        if i1 > i2 {
            // insert as (i1-1)th bit, will be shifted left 1 by next line
            retval = index1(b1, i1-1, k)
            retval = index1(b2, i2, retval)
        }
        else { // i2>i1
            // insert as (i2-1)th bit, will be shifted left 1 by next line
            retval = index1(b2, i2-1, k)
            retval = index1(b1, i1, retval)
        }
        return retval
    }

    /**
     Enlarge single operator to n qubits.

     It is exponential in the number of qubits.
     opt is the single-qubit opt.
     qubit is the qubit to apply it on counts from 0 and order
     is q_{n-1} ... otimes q_1 otimes q_0.
     number_of_qubits is the number of qubits in the system.
     */
    static func enlarge_single_opt(_ opt: [[Complex]], _ qubit: Int, _ number_of_qubits: Int) -> [[Complex]] {
        let temp_1 = NumUtilities.identityComplex(Int(pow(2.0,Double(number_of_qubits-qubit-1))))
        let temp_2 = NumUtilities.identityComplex(Int(pow(2.0,Double(qubit))))
        return NumUtilities.kronComplex(temp_1, NumUtilities.kronComplex(opt, temp_2))
    }

    /**
     Enlarge two-qubit operator to n qubits.

     It is exponential in the number of qubits.
     opt is the two-qubit gate
     q0 is the first qubit (control) counts from 0
     q1 is the second qubit (target)
     returns a complex numpy array
     number_of_qubits is the number of qubits in the system.
     */
    static func enlarge_two_opt(_ opt: [[Complex]], _ q0: Int, _ q1: Int, _ num: Int) -> [[Complex]] {
        var enlarge_opt = NumUtilities.zeroComplex(1 << (num), 1 << (num))
        for i in 0..<(1 << (num-2)) {
            for j in 0..<2 {
                for k in 0..<2 {
                    for jj in 0..<2 {
                        for kk in 0..<2 {
                            enlarge_opt[index2(j, q0, k, q1, i)][index2(jj, q0, kk, q1, i)] = opt[j+2*k][jj+2*kk]
                        }
                    }
                }
            }
        }
        return enlarge_opt
    }
}
