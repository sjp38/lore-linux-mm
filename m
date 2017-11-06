Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8406B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:36:04 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j15so6539744wre.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:36:04 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p6si9748856edk.106.2017.11.06.10.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 10:36:02 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 0/2] don't use vmemmap_populate() to initialize shadow
Date: Mon,  6 Nov 2017 13:35:14 -0500
Message-Id: <20171106183516.6644-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Corrected "From" fields in these two patches to preserve the original
authorship.

Andrey Ryabinin (1):
  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow

Will Deacon (1):
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
