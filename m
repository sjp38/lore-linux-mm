Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id F045D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 20-v6so1573144ois.21
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:52:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i17-v6si4594724otl.242.2018.09.18.05.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 05:52:16 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8IConPt115811
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:54:10 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mk0byc1y6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:54:10 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 18 Sep 2018 13:52:13 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [RFC][PATCH 0/2] convert s390 to generic mmu_gather
Date: Tue, 18 Sep 2018 14:51:49 +0200
Message-Id: <20180918125151.31744-1-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi Peter,

as an add-on for the TLB flushing changes two patches to make
s390 use the generic mmu_gather code as well. I let it run for
a few hours with several TLB stress tests, no fallout so far.
It certainly can use more testing but it looks ok to me.

Martin Schwidefsky (2):
  asm-generic/tlb: introduce HAVE_MMU_GATHER_NO_GATHER
  s390/tlb: convert to generic mmu_gather

 arch/Kconfig                |   3 +
 arch/s390/Kconfig           |   3 +
 arch/s390/include/asm/tlb.h | 130 ++++++++++++++------------------------------
 arch/s390/mm/pgalloc.c      |  63 +--------------------
 include/asm-generic/tlb.h   |   9 ++-
 mm/mmu_gather.c             | 114 ++++++++++++++++++++++----------------
 6 files changed, 121 insertions(+), 201 deletions(-)

-- 
2.16.4
