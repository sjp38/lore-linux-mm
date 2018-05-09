Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 605536B0325
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:56:46 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b31-v6so2846449plb.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:56:46 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id t5-v6si23808600plo.113.2018.05.08.18.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 18:56:44 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 5/8] x86/pkeys: Move vma_pkey() into asm/pkeys.h
In-Reply-To: <f9240079-2ff2-9d3f-ba15-fefe65c67779@intel.com>
References: <20180508145948.9492-1-mpe@ellerman.id.au> <20180508145948.9492-6-mpe@ellerman.id.au> <f9240079-2ff2-9d3f-ba15-fefe65c67779@intel.com>
Date: Wed, 09 May 2018 11:56:39 +1000
Message-ID: <87o9hpzj54.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Dave Hansen <dave.hansen@intel.com> writes:

> On 05/08/2018 07:59 AM, Michael Ellerman wrote:
>> Move the last remaining pkey helper, vma_pkey() into asm/pkeys.h
>
> Fine with me, as long as it compiles. :)

Yeah fair point :)

It survived the kbuild robot, so fingers crossed. I'll let it sit in
linux-next for a while too.

cheers


From: kbuild test robot <lkp@intel.com> (Today 04:11)
Subject: [powerpc:topic/pkey] BUILD SUCCESS 1a03cd3b474084aaa967f646379495a14716632d
To: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 09 May 2018 02:11:24 +0800

tree/branch: https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git  topic/pkey
branch HEAD: 1a03cd3b474084aaa967f646379495a14716632d  mm/pkeys, x86, powerpc: Display pkey in smaps if arch supports pkeys

elapsed time: 194m

configs tested: 113

The following configs have been built successfully.
More configs may be tested in the coming days.

i386                               tinyconfig
i386                   randconfig-x010-201818
i386                   randconfig-x011-201818
i386                   randconfig-x012-201818
i386                   randconfig-x013-201818
i386                   randconfig-x014-201818
i386                   randconfig-x015-201818
i386                   randconfig-x016-201818
i386                   randconfig-x017-201818
i386                   randconfig-x018-201818
i386                   randconfig-x019-201818
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i1-201818
i386                     randconfig-i0-201818
alpha                               defconfig
parisc                            allnoconfig
parisc                         b180_defconfig
parisc                        c3000_defconfig
parisc                              defconfig
x86_64                 randconfig-x010-201818
x86_64                 randconfig-x011-201818
x86_64                 randconfig-x012-201818
x86_64                 randconfig-x013-201818
x86_64                 randconfig-x014-201818
x86_64                 randconfig-x015-201818
x86_64                 randconfig-x016-201818
x86_64                 randconfig-x017-201818
x86_64                 randconfig-x018-201818
x86_64                 randconfig-x019-201818
x86_64                                  kexec
x86_64                              federa-25
x86_64                                   rhel
x86_64                               rhel-7.2
i386                     randconfig-a0-201818
i386                     randconfig-a1-201818
x86_64                 randconfig-s0-05090041
x86_64                 randconfig-s1-05090041
x86_64                 randconfig-s2-05090041
openrisc                    or1ksim_defconfig
um                             i386_defconfig
um                           x86_64_defconfig
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
i386                     randconfig-s1-201818
i386                     randconfig-s0-201818
x86_64                 randconfig-s3-05090001
x86_64                 randconfig-s4-05090001
x86_64                 randconfig-s5-05090001
x86_64                   randconfig-i0-201818
i386                   randconfig-b0-05090042
x86_64                 randconfig-u0-05090045
c6x                        evmc6678_defconfig
h8300                    h8300h-sim_defconfig
nios2                         10m50_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
i386                             allmodconfig
i386                   randconfig-x008-201818
i386                   randconfig-x006-201818
i386                   randconfig-x000-201818
i386                   randconfig-x004-201818
i386                   randconfig-x009-201818
i386                   randconfig-x003-201818
i386                   randconfig-x001-201818
i386                   randconfig-x002-201818
i386                   randconfig-x005-201818
i386                   randconfig-x007-201818
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
i386                   randconfig-x073-201818
i386                   randconfig-x075-201818
i386                   randconfig-x079-201818
i386                   randconfig-x071-201818
i386                   randconfig-x076-201818
i386                   randconfig-x074-201818
i386                   randconfig-x078-201818
i386                   randconfig-x077-201818
i386                   randconfig-x070-201818
i386                   randconfig-x072-201818
x86_64                 randconfig-x002-201818
x86_64                 randconfig-x006-201818
x86_64                 randconfig-x005-201818
x86_64                 randconfig-x001-201818
x86_64                 randconfig-x009-201818
x86_64                 randconfig-x004-201818
x86_64                 randconfig-x003-201818
x86_64                 randconfig-x007-201818
x86_64                 randconfig-x000-201818
x86_64                 randconfig-x008-201818
ia64                             alldefconfig
ia64                              allnoconfig
ia64                                defconfig
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
