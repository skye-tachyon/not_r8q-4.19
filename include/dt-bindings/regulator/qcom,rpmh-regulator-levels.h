/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (c) 2018-2019, The Linux Foundation. All rights reserved.
 */

#ifndef __QCOM_RPMH_REGULATOR_LEVELS_H
#define __QCOM_RPMH_REGULATOR_LEVELS_H

/* These levels may be used for ARC type RPMh regulators. */
/* Undervolted by one bin down */
#define RPMH_REGULATOR_LEVEL_RETENTION	8
#define RPMH_REGULATOR_LEVEL_MIN_SVS	16
#define RPMH_REGULATOR_LEVEL_LOW_SVS	48
#define RPMH_REGULATOR_LEVEL_LOW_SVS_L1	64
#define RPMH_REGULATOR_LEVEL_LOW_SVS_L2	96
#define RPMH_REGULATOR_LEVEL_SVS	112
#define RPMH_REGULATOR_LEVEL_SVS_L0	128
#define RPMH_REGULATOR_LEVEL_SVS_L1	144
#define RPMH_REGULATOR_LEVEL_SVS_L2	192
#define RPMH_REGULATOR_LEVEL_NOM	224
#define RPMH_REGULATOR_LEVEL_NOM_L1	256
#define RPMH_REGULATOR_LEVEL_NOM_L2	320
#define RPMH_REGULATOR_LEVEL_TURBO	336
#define RPMH_REGULATOR_LEVEL_TURBO_L1	384
#define RPMH_REGULATOR_LEVEL_TURBO_L2	416
#define RPMH_REGULATOR_LEVEL_TURBO_NO_CPR  512
#define RPMH_REGULATOR_LEVEL_MAX	65534

/*
 * These set constants may be used as the value for qcom,set of an RPMh
 * resource device.
 */
#define RPMH_REGULATOR_SET_ACTIVE	1
#define RPMH_REGULATOR_SET_SLEEP	2
#define RPMH_REGULATOR_SET_ALL		3

/*
 * These mode constants may be used for qcom,supported-modes and qcom,init-mode
 * properties of an RPMh resource.  Each type of regulator supports a subset of
 * the possible modes.
 *
 * %RPMH_REGULATOR_MODE_PASS:	Pass-through mode in which output is directly
 *				tied to input.  This mode is only supported by
 *				BOB type regulators.
 * %RPMH_REGULATOR_MODE_RET:	Retention mode in which only an extremely small
 *				load current is allowed.  This mode is supported
 *				by LDO and SMPS type regulators.
 * %RPMH_REGULATOR_MODE_LPM:	Low power mode in which a small load current is
 *				allowed.  This mode corresponds to PFM for SMPS
 *				and BOB type regulators.  This mode is supported
 *				by LDO, HFSMPS, BOB, and PMIC4 FTSMPS type
 *				regulators.
 * %RPMH_REGULATOR_MODE_AUTO:	Auto mode in which the regulator hardware
 *				automatically switches between LPM and HPM based
 *				upon the real-time load current.  This mode is
 *				supported by HFSMPS, BOB, and PMIC4 FTSMPS type
 *				regulators.
 * %RPMH_REGULATOR_MODE_HPM:	High power mode in which the full rated current
 *				of the regulator is allowed.  This mode
 *				corresponds to PWM for SMPS and BOB type
 *				regulators.  This mode is supported by all types
 *				of regulators.
 */
#define RPMH_REGULATOR_MODE_PASS	0
#define RPMH_REGULATOR_MODE_RET		1
#define RPMH_REGULATOR_MODE_LPM		2
#define RPMH_REGULATOR_MODE_AUTO	3
#define RPMH_REGULATOR_MODE_HPM		4

#endif
