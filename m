Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F22E38E000C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:29:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e15-v6so2650658pfi.5
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:29:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s68-v6si3921941pgc.16.2018.09.13.02.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 02:29:26 -0700 (PDT)
Message-ID: <20180913092110.817204997@infradead.org>
Date: Thu, 13 Sep 2018 11:21:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 00/11] my generic mmu_gather patches
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

Hi,

Here are some further mmu_gather/tlb patches I have that go on top of Will's
current tlb branch.

I mostly wrote them 2 weeks ago and haven't been able to get back to them; but
Will offered to have a wee look.

Esp. the full arch conversions (ARM, SH, UM, IA64) were based on patches I did
7 years ago and haven't been tested other than with a compiler.

The notable exception is s390, which after this series, is the only remaining
architecture with a private mmu_gather implementation. I didn't get around to
converting that.

Anyway, have a look, hopefully there's a few good bits in :-)
