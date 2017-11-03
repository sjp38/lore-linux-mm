Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 588416B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 14:52:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 5so1352280wmk.0
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 11:52:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 59si1289155edy.340.2017.11.03.11.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 11:52:33 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 0/2] don't use vmemmap_populate() to initialize shadow
Date: Fri,  3 Nov 2017 14:51:45 -0400
Message-Id: <20171103185147.2688-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Andrey Ryabinin asked to replace the three patches in my series:

x86-kasan-add-and-use-kasan_map_populate.patch
arm64-kasan-add-and-use-kasan_map_populate.patch
arm64-kasan-avoid-using-vmemmap_populate-to-initialise-shadow.patch

With two patches in this thread:

x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow

Pavel Tatashin (2):
  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
  arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow

 arch/arm64/Kconfig          |   2 +-
 arch/arm64/mm/kasan_init.c  | 130 ++++++++++++++++++++++++----------------
 arch/x86/Kconfig            |   2 +-
 arch/x86/mm/kasan_init_64.c | 143 +++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 218 insertions(+), 59 deletions(-)

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
