-- SPDX-License-Identifier: PMPL-1.0-or-later
-- KRL example: trefoil knot
-- Pronounced "curl" — the Knot Resolution Language

-- CONSTRUCT: three positive crossings on a 2-braid, then close
let trefoil = close (sigma 1 ; sigma 1 ; sigma 1) ;

-- TRANSFORM: mirror gives the left-handed trefoil
let trefoil_mirror = mirror trefoil ;

-- RESOLVE: simplify (should be idempotent for canonical trefoil)
let simplified = simplify trefoil ;
