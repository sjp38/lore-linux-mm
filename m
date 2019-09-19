Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66548C49ED7
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A126217D6
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:23:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A126217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB13F6B033F; Thu, 19 Sep 2019 03:23:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3B666B0341; Thu, 19 Sep 2019 03:23:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929AE6B0342; Thu, 19 Sep 2019 03:23:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAF96B033F
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 03:23:08 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D1D501E080
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:23:07 +0000 (UTC)
X-FDA: 75950828814.17.sack69_7277e82a15815
X-HE-Tag: sack69_7277e82a15815
X-Filterd-Recvd-Size: 5030
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:23:06 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Sep 2019 00:23:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,522,1559545200"; 
   d="scan'208";a="189521124"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga003.jf.intel.com with ESMTP; 19 Sep 2019 00:23:03 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1iAqmM-000EY1-R5; Thu, 19 Sep 2019 15:23:02 +0800
Date: Thu, 19 Sep 2019 15:22:51 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:pending-fixes] BUILD SUCCESS
 cd0a293e6cef4a0111ed8d5c7f9350aa1c9096c1
Message-ID: <5d832ccb.pdN6DPY83l1S7otY%lkp@intel.com>
User-Agent: Heirloom mailx 12.5 6/20/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree/branch: https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git  pending-fixes
branch HEAD: cd0a293e6cef4a0111ed8d5c7f9350aa1c9096c1  Merge remote-tracking branch 'pidfd-fixes/fixes'

elapsed time: 54m

configs tested: 68

The following configs have been built successfully.
More configs may be tested in the coming days.

ia64                             alldefconfig
ia64                             allmodconfig
ia64                              allnoconfig
ia64                                defconfig
h8300                     edosk2674_defconfig
h8300                    h8300h-sim_defconfig
h8300                       h8s-sim_defconfig
m68k                             allmodconfig
m68k                       m5475evb_defconfig
m68k                          multi_defconfig
m68k                           sun3_defconfig
x86_64                           allyesconfig
i386                             allmodconfig
i386                             alldefconfig
i386                              allnoconfig
i386                                defconfig
parisc                            allnoconfig
parisc                         b180_defconfig
parisc                        c3000_defconfig
parisc                              defconfig
arc                              allyesconfig
arc                                 defconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
powerpc                           allnoconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
alpha                               defconfig
nds32                             allnoconfig
nds32                               defconfig
riscv                             allnoconfig
riscv                               defconfig
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                              fedora-25
x86_64                                  kexec
x86_64                                    lkp
x86_64                                nfsroot
x86_64                                   rhel
x86_64                               rhel-7.6
um                                  defconfig
um                             i386_defconfig
um                           x86_64_defconfig
c6x                              allyesconfig
c6x                        evmc6678_defconfig
nios2                         10m50_defconfig
nios2                         3c120_defconfig
openrisc                    or1ksim_defconfig
openrisc                 simple_smp_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
sparc                               defconfig
sparc64                          allmodconfig
sparc64                           allnoconfig
sparc64                             defconfig
mips                           32r2_defconfig
mips                         64r6el_defconfig
mips                             allmodconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                                     txx9
sh                               allmodconfig
sh                                allnoconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                            titan_defconfig

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

