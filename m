Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E4AB56B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 13:05:05 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so2137634pad.2
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 10:05:05 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ta1si3360157pab.154.2014.04.03.10.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 10:05:05 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv5 0/2] Remove ARM meminfo
Date: Thu,  3 Apr 2014 10:04:56 -0700
Message-Id: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

Hi,

This is v5 of the series to remove meminfo and use memblock
directly. This has been validated with/without highmem although
SPARSEMEM has not been validated. Reviews/testing welcome.

Thanks,
Laura

v5: Folded in patch from Nicolas, addressed several issues found by
Russell with fixes suggested by Grygorii. Whitespace cleanup.

v4: Added nommu support. Fixed issues with !HIGHMEM per Grygorii Strashko.

v3: Fixed compilation issue for CONFIG_SPARSEMEM. Fixed several typos
in spitz.c. Removed early_init_dt_add_memory_arch per Grant's suggestion.

v2: Implemented full commandline support for mem@addr


Laura Abbott (2):
  mm/memblock: add memblock_get_current_limit
  arm: Get rid of meminfo

 arch/arm/Kconfig                         |   5 --
 arch/arm/boot/compressed/atags_to_fdt.c  |   2 +
 arch/arm/include/asm/mach/arch.h         |   4 +-
 arch/arm/include/asm/memblock.h          |   3 +-
 arch/arm/include/asm/setup.h             |  28 --------
 arch/arm/kernel/atags_parse.c            |   5 +-
 arch/arm/kernel/devtree.c                |   5 --
 arch/arm/kernel/setup.c                  |  30 +++-----
 arch/arm/mach-clps711x/board-clep7312.c  |   7 +-
 arch/arm/mach-clps711x/board-edb7211.c   |  10 ++-
 arch/arm/mach-clps711x/board-p720t.c     |   2 +-
 arch/arm/mach-footbridge/cats-hw.c       |   2 +-
 arch/arm/mach-footbridge/netwinder-hw.c  |   2 +-
 arch/arm/mach-msm/board-halibut.c        |   6 --
 arch/arm/mach-msm/board-mahimahi.c       |  13 ++--
 arch/arm/mach-msm/board-msm7x30.c        |   3 +-
 arch/arm/mach-msm/board-sapphire.c       |  13 ++--
 arch/arm/mach-msm/board-trout.c          |   8 +--
 arch/arm/mach-orion5x/common.c           |   3 +-
 arch/arm/mach-orion5x/common.h           |   3 +-
 arch/arm/mach-pxa/cm-x300.c              |   3 +-
 arch/arm/mach-pxa/corgi.c                |  10 ++-
 arch/arm/mach-pxa/eseries.c              |   9 ++-
 arch/arm/mach-pxa/poodle.c               |   8 +--
 arch/arm/mach-pxa/spitz.c                |   8 +--
 arch/arm/mach-pxa/tosa.c                 |   8 +--
 arch/arm/mach-realview/core.c            |  11 ++-
 arch/arm/mach-realview/core.h            |   3 +-
 arch/arm/mach-realview/realview_pb1176.c |   8 +--
 arch/arm/mach-realview/realview_pbx.c    |  17 ++---
 arch/arm/mach-s3c24xx/mach-smdk2413.c    |   8 +--
 arch/arm/mach-s3c24xx/mach-vstms.c       |   8 +--
 arch/arm/mach-sa1100/assabet.c           |   2 +-
 arch/arm/mm/init.c                       |  72 ++++++++-----------
 arch/arm/mm/mmu.c                        | 117 +++++++++----------------------
 arch/arm/mm/nommu.c                      |  66 +++++++++--------
 include/linux/memblock.h                 |   2 +
 mm/memblock.c                            |   5 ++
 38 files changed, 186 insertions(+), 333 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
