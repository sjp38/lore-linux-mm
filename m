Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7896B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 09:42:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o7-v6so4579807pgc.23
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 06:42:21 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 84-v6si14872119pfa.60.2018.06.08.06.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 06:42:18 -0700 (PDT)
Date: Fri, 08 Jun 2018 21:42:15 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master] BUILD REGRESSION
 7393732bae530daa27567988b91d16ecfeef6c62
Message-ID: <5b1a87b7.7PNFYCcgPGh68IFP%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

tree/branch: git://git.cmpxchg.org/linux-mmotm.git  master
branch HEAD: 7393732bae530daa27567988b91d16ecfeef6c62  pci: test for unexpectedly disabled bridges

Regressions in current branch:

drivers/scsi//qedf/qedf_main.c:3569:6: error: redefinition of 'qedf_get_protocol_tlv_data'
drivers/scsi/qedf/qedf_main.c:3569:6: error: redefinition of 'qedf_get_protocol_tlv_data'
drivers/scsi//qedf/qedf_main.c:3649:6: error: redefinition of 'qedf_get_generic_tlv_data'
drivers/scsi/qedf/qedf_main.c:3649:6: error: redefinition of 'qedf_get_generic_tlv_data'
drivers/thermal/qcom/tsens.c:144:31: error: 's' undeclared (first use in this function)
fs/dax.c:1031:2: error: 'entry2' undeclared (first use in this function)
fs/dax.c:1031:2: error: 'entry2' undeclared (first use in this function); did you mean 'entry'?
fs/fat/inode.c:162:25: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
fs/fat/inode.c:162:3: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t' [-Wformat=]
fs///fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
fs/fat/inode.c:163:9: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'sector_t {aka long long unsigned int}' [-Wformat=]
include/asm-generic/int-ll64.h:16:9: error: unknown type name '__s8'
include/net/ipv6.h:299:2: error: unknown type name '__s8'
include/uapi/asm-generic/int-ll64.h:20:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'typedef'
include/uapi/linux/dqblk_xfs.h:54:2: error: unknown type name '__s8'
include/uapi/linux/ethtool.h:1834:2: error: unknown type name '__s8'
include/uapi/linux/if_bonding.h:107:2: error: unknown type name '__s8'
net/ipv4/ipconfig.c:1:2: error: expected ';' before 'typedef'
/tmp/ccUZEe25.s:35: Error: .err encountered

Error ids grouped by kconfigs:

recent_errors
a??a??a?? arm64-allmodconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? fs-dax.c:error:entry2-undeclared-(first-use-in-this-function)-did-you-mean-entry
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm64-defconfig
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-allmodconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? :Error:.err-encountered
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-arm5
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-arm67
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-at91_dt_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-exynos_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-imx_v6_v7_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-ixp4xx_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-multi_v5_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-multi_v7_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-mvebu_v7_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-omap2plus_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-sa1100
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-samsung
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-sh
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-shmobile_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-sunxi_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? arm-tegra_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? i386-allmodconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? i386-defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??a??a?? i386-randconfig-a0-201822
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t
a??a??a?? i386-randconfig-i0-201822
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? i386-randconfig-i1-201822
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? i386-randconfig-s0-201822-CONFIG_DEBUG_INFO_REDUCED
a??A A  a??a??a?? fs-dax.c:error:entry2-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? ia64-allmodconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? fs-dax.c:error:entry2-undeclared-(first-use-in-this-function)-did-you-mean-entry
a??A A  a??a??a?? net-ipv4-ipconfig.c:error:expected-before-typedef
a??a??a?? m68k-multi_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? m68k-sun3_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? mips-fuloong2e_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? mips-jz4740
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? mips-malta_kvm_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? mips-txx9
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? nios2-10m50_defconfig
a??A A  a??a??a?? net-ipv4-ipconfig.c:error:expected-before-typedef
a??a??a?? parisc-b180_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? parisc-c3000_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? parisc-defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? powerpc-defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? powerpc-ppc64_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sh-allmodconfig
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??a??a?? sh-allyesconfig
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sh-rsk7269_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sh-sh7785lcr_32bit_defconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sh-titan_defconfig
a??A A  a??a??a?? fs-fat-inode.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-sector_t-aka-long-long-unsigned-int
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sparc64-allyesconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sparc-allyesconfig
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_generic_tlv_data
a??A A  a??a??a?? drivers-scsi-qedf-qedf_main.c:error:redefinition-of-qedf_get_protocol_tlv_data
a??A A  a??a??a?? drivers-thermal-qcom-tsens.c:error:s-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? sparc-defconfig
a??A A  a??a??a?? net-ipv4-ipconfig.c:error:expected-before-typedef
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? x86_64-fedora-25
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? x86_64-kexec
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? x86_64-randconfig-i0-201822
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? x86_64-rhel
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? x86_64-rhel-7.2
a??A A  a??a??a?? include-asm-generic-int-ll64.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-net-ipv6.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-asm-generic-int-ll64.h:error:expected-asm-or-__attribute__-before-typedef
a??A A  a??a??a?? include-uapi-linux-dqblk_xfs.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-ethtool.h:error:unknown-type-name-__s8
a??A A  a??a??a?? include-uapi-linux-if_bonding.h:error:unknown-type-name-__s8
a??a??a?? xtensa-common_defconfig
a??A A  a??a??a?? net-ipv4-ipconfig.c:error:expected-before-typedef
a??a??a?? xtensa-iss_defconfig
    a??a??a?? net-ipv4-ipconfig.c:error:expected-before-typedef

elapsed time: 794m

configs tested: 132

x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
i386                     randconfig-n0-201822
i386                     randconfig-i0-201822
i386                     randconfig-i1-201822
x86_64                                  kexec
x86_64                                   rhel
x86_64                               rhel-7.2
x86_64                              fedora-25
arm                       omap2plus_defconfig
arm                                    sa1100
arm                              allmodconfig
arm                                   samsung
arm                        mvebu_v7_defconfig
arm                          ixp4xx_defconfig
arm                       imx_v6_v7_defconfig
arm64                            allmodconfig
arm                           tegra_defconfig
arm                                      arm5
arm64                            alldefconfig
arm                                        sh
arm                                     arm67
i386                     randconfig-a0-201822
i386                     randconfig-a1-201822
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
i386         randconfig-s0-201822-CONFIG_DEBUG_INFO_REDUCED
i386                     randconfig-s0-201822
i386                     randconfig-s1-201822
i386                               tinyconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                   randconfig-i0-201822
x86_64                           allmodconfig
i386                   randconfig-x012-201822
i386                   randconfig-x016-201822
i386                   randconfig-x014-201822
i386                   randconfig-x017-201822
i386                   randconfig-x018-201822
i386                   randconfig-x013-201822
i386                   randconfig-x011-201822
i386                   randconfig-x015-201822
i386                   randconfig-x019-201822
i386                   randconfig-x010-201822
i386                             allmodconfig
x86_64                 randconfig-x011-201822
x86_64                 randconfig-x015-201822
x86_64                 randconfig-x018-201822
x86_64                 randconfig-x010-201822
x86_64                 randconfig-x014-201822
x86_64                 randconfig-x019-201822
x86_64                 randconfig-x013-201822
x86_64                 randconfig-x017-201822
x86_64                 randconfig-x016-201822
x86_64                 randconfig-x012-201822
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
i386                   randconfig-x009-201822
i386                   randconfig-x008-201822
i386                   randconfig-x005-201822
i386                   randconfig-x001-201822
i386                   randconfig-x003-201822
i386                   randconfig-x000-201822
i386                   randconfig-x004-201822
i386                   randconfig-x006-201822
i386                   randconfig-x002-201822
i386                   randconfig-x007-201822
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                           efm32_defconfig
arm64                               defconfig
arm                        multi_v5_defconfig
arm                           sunxi_defconfig
arm64                             allnoconfig
arm                          exynos_defconfig
arm                        shmobile_defconfig
arm                        multi_v7_defconfig
i386                   randconfig-x078-201822
i386                   randconfig-x079-201822
i386                   randconfig-x070-201822
i386                   randconfig-x074-201822
i386                   randconfig-x076-201822
i386                   randconfig-x075-201822
i386                   randconfig-x071-201822
i386                   randconfig-x073-201822
i386                   randconfig-x077-201822
i386                   randconfig-x072-201822
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
x86_64                 randconfig-x003-201822
x86_64                 randconfig-x007-201822
x86_64                 randconfig-x000-201822
x86_64                 randconfig-x004-201822
x86_64                 randconfig-x005-201822
x86_64                 randconfig-x001-201822
x86_64                 randconfig-x008-201822
x86_64                 randconfig-x002-201822
x86_64                 randconfig-x006-201822
x86_64                 randconfig-x009-201822

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
