# Error Control Coding & Modulation Simulation (MATLAB)

## Overview

This project implements and evaluates digital communication systems using M-PAM modulation, combined with:

* Hamming Codes (block coding)
* Regular LDPC Codes
* Irregular LDPC Codes
* Peeling Decoding Algorithm
* Security-oriented LDPC Design (Bob vs Eve scenario)

The performance is analyzed in terms of:

* Bit Error Rate (BER)
* Throughput
* Effect of SNR and erasures


## Features

### 1. Hamming Coding System

* Supports:

  * Hamming (7,4)
  * Hamming (15,11)
* Includes:

  * Encoding (`hamming_encode`)
  * Decoding with error correction (`hamming_decode`)
* Simulated over:

  * 4-PAM
  * 8-PAM
* Uses:

  * Gray Mapping
  * AWGN Channel
  * Minimum Distance Detection

### 2. Uncoded vs Coded M-PAM

* Comparison between:

  * Uncoded transmission
  * Hamming-coded transmission
* Metrics:

  * BER vs SNR
  * Throughput vs SNR

### 3. Regular LDPC Codes

* Construction of (dv, dc)-regular LDPC matrices
* Example:

  * (3,6) LDPC code
* Includes:

  * Peeling Decoder for erasure channels
* Channel model:

  * AWGN with erasure thresholding


### 4. Irregular LDPC Codes

* Optimization-based design:

  * Degree distributions (λ, ρ)
* Linear programming is used for:

  * Improving decoding performance
* Includes:

  * Custom LDPC matrix generation
  * Iterative decoding

### 5. Security Scenario (Bob vs Eve)

* Simulates a wiretap-like setup:

  * Bob: lower erasure probability
  * Eve: higher erasure probability
* Objective:

  * Reliable decoding for Bob
  * High BER for Eve

