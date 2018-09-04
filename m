Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE4166B6D50
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:45:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so3842073oix.2
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:45:21 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v2-v6si14419793oia.448.2018.09.04.04.45.20
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:45:20 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 5/5] MAINTAINERS: Add entry for MMU GATHER AND TLB INVALIDATION
Date: Tue,  4 Sep 2018 12:45:33 +0100
Message-Id: <1536061533-16188-6-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

We recently had to debug a TLB invalidation problem on the munmap()
path, which was made more difficult than necessary because:

  (a) The MMU gather code had changed without people realising
  (b) Many people subtly misunderstood the operation of the MMU gather
      code and its interactions with RCU and arch-specific TLB invalidation
  (c) Untangling the intended behaviour involved educated guesswork and
      plenty of discussion

Hopefully, we can avoid getting into this mess again by designating a
cross-arch group of people to look after this code. It is not intended
that they will have a separate tree, but they at least provide a point
of contact for anybody working in this area and can co-ordinate any
proposed future changes to the internal API.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 MAINTAINERS | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9ad052aeac39..e490a0a0605a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9681,6 +9681,18 @@ S:	Maintained
 F:	arch/arm/boot/dts/mmp*
 F:	arch/arm/mach-mmp/
 
+MMU GATHER AND TLB INVALIDATION
+M:	Will Deacon <will.deacon@arm.com>
+M:	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
+M:	Nick Piggin <npiggin@gmail.com>
+M:	Peter Zijlstra <peterz@infradead.org>
+L:	linux-arch@vger.kernel.org
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	arch/*/include/asm/tlb.h
+F:	include/asm-generic/tlb.h
+F:	mm/mmu_gather.c
+
 MN88472 MEDIA DRIVER
 M:	Antti Palosaari <crope@iki.fi>
 L:	linux-media@vger.kernel.org
-- 
2.1.4
