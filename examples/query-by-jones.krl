-- SPDX-License-Identifier: PMPL-1.0-or-later
-- KRL example: RETRIEVE — query by invariant

-- Define a reference knot
let target = close (sigma 1 ; sigma 1 ; sigma 1) ;

-- Retrieve all knots matching target's Jones polynomial and under 8 crossings
find where jones = target and crossing < 8 ;

-- Retrieve knots by crossing number range
find where crossing >= 3 and crossing <= 5 ;
