Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFF1D6B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:47:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id ce7-v6so424432plb.22
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:47:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b13-v6si20043493pgg.89.2018.10.09.00.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 00:47:21 -0700 (PDT)
Date: Tue, 9 Oct 2018 09:47:16 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm: In the PTE swapout page reclaim case clear the
 accessed bit instead of flushing the TLB
Message-ID: <20181009074716.GG5663@hirez.programming.kicks-ass.net>
References: <1539059570-9043-1-git-send-email-amhetre@nvidia.com>
 <20181009071637.GF5663@hirez.programming.kicks-ass.net>
 <296A2DAD-8859-4CA0-8D04-3AFA13FEEBE9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <296A2DAD-8859-4CA0-8D04-3AFA13FEEBE9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Ashish Mhetre <amhetre@nvidia.com>, vdumpa@nvidia.com, avanbrunt@nvidia.com, Snikam@nvidia.com, praithatha@nvidia.com, Shaohua Li <shli@kernel.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Tue, Oct 09, 2018 at 12:20:58AM -0700, Nadav Amit wrote:
> What am I missing? This is a patch from 2014, no? b13b1d2d8692b ?

Ha!, clearly you're more awake than me ;-)

I'll go grab more of the morning juice...
