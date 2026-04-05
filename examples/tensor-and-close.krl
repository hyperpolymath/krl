-- SPDX-License-Identifier: PMPL-1.0-or-later
-- KRL example: CONSTRUCT using tensor product + closure

-- Two strands with crossings placed side by side, then closed
let left_part  = sigma 1 ; sigma 1 ;
let right_part = sigma_inv 1 ;

-- Tensor (juxtapose) then close
let linked = close (left_part | right_part) ;
