Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31DE16B0007
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 05:01:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t78-v6so6676705pfa.8
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 02:01:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o18-v6sor2267636pfe.80.2018.07.06.02.01.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 02:01:51 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [RESEND PATCH v10 1/6] arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
Date: Fri,  6 Jul 2018 17:01:10 +0800
Message-Id: <1530867675-9018-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Make CONFIG_HAVE_MEMBLOCK_PFN_VALID a new config option so it can move
memblock_next_valid_pfn to generic code file. All the latter optimizations
are based on this config.

The memblock initialization time on arm/arm64 can benefit from this.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/arm/Kconfig   | 4 ++++
 arch/arm64/Kconfig | 4 ++++
 mm/Kconfig         | 3 +++
 3 files changed, 11 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 843edfd..7ea2636 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1642,6 +1642,10 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
+config HAVE_MEMBLOCK_PFN_VALID
+	def_bool y
+	depends on HAVE_ARCH_PFN_VALID
+
 config HAVE_GENERIC_GUP
 	def_bool y
 	depends on ARM_LPAE
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 42c090c..26d75f4 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -778,6 +778,10 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
+config HAVE_MEMBLOCK_PFN_VALID
+	def_bool y
+	depends on HAVE_ARCH_PFN_VALID
+
 config HW_PERF_EVENTS
 	def_bool y
 	depends on ARM_PMU
diff --git a/mm/Kconfig b/mm/Kconfig
index 94af022..28fcf54 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	bool
 
+config HAVE_MEMBLOCK_PFN_VALID
+	bool
+
 config HAVE_GENERIC_GUP
 	bool
 
-- 
1.8.3.1
