Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C68848E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:30:49 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i188-v6so7093077itf.6
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:30:49 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v187-v6si12596259iof.126.2018.09.19.04.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 04:30:48 -0700 (PDT)
Date: Wed, 19 Sep 2018 13:30:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 07/11] arm/tlb: Convert to generic mmu_gather
Message-ID: <20180919113033.GB24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.247989787@infradead.org>
 <20180918141034.GF16498@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180918141034.GF16498@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Tue, Sep 18, 2018 at 03:10:34PM +0100, Will Deacon wrote:
> > +	addr = (addr & PMD_MASK) + SZ_1M;
> > +	__tlb_adjust_range(tlb, addr - PAGE_SIZE, addr + PAGE_SIZE);
> 
> Hmm, I don't think you've got the range correct here. Don't we want
> something like:
> 
> 	__tlb_adjust_range(tlb, addr - PAGE_SIZE, 2 * PAGE_SIZE)
> 
> to ensure that we flush on both sides of the 1M boundary?

Argh indeed. I confused {start,size} with {start,end}. Thanks!
