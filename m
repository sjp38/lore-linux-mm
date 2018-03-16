Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6CD16B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:57:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 140-v6so1581797itg.4
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:57:24 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 137-v6si4038459itb.76.2018.03.16.06.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Mar 2018 06:57:23 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:57:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] Improve mutex documentation
Message-ID: <20180316135716.GG4064@hirez.programming.kicks-ass.net>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180315115812.GA9949@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315115812.GA9949@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab@kernel.org>, Ingo Molnar <mingo@redhat.com>

On Thu, Mar 15, 2018 at 04:58:12AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
> > My memory is weak and our documentation is awful.  What does
> > mutex_lock_killable() actually do and how does it differ from
> > mutex_lock_interruptible()?
> 
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Add kernel-doc for mutex_lock_killable() and mutex_lock_io().  Reword the
> kernel-doc for mutex_lock_interruptible().
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Thanks Matthew!
