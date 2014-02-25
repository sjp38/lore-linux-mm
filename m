Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id D81876B00D5
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:37:36 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id 9so19700199ykp.1
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:37:36 -0800 (PST)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id x72si5336519yhi.143.2014.02.25.10.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 10:37:36 -0800 (PST)
Message-ID: <1393353454.2577.42.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 25 Feb 2014 10:37:34 -0800
In-Reply-To: <20140225183522.GU6835@laptop.programming.kicks-ass.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	 <20140225183522.GU6835@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-02-25 at 19:35 +0100, Peter Zijlstra wrote:
> On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> > +void vmacache_update(struct mm_struct *mm, unsigned long addr,
> > +		     struct vm_area_struct *newvma)
> > +{
> > +	/*
> > +	 * Hash based on the page number. Provides a good
> > +	 * hit rate for workloads with good locality and
> > +	 * those with random accesses as well.
> > +	 */
> > +	int idx = (addr >> PAGE_SHIFT) & 3;
> 
>  % VMACACHE_SIZE
> 
> perhaps? GCC should turn that into a mask for all sensible values I
> would think.
> 
> Barring that I think something like:
> 
> #define VMACACHE_BITS	2
> #define VMACACHE_SIZE	(1U << VMACACHE_BITS)
> #define VMACACHE_MASK	(VMACACHE_SIZE - 1)

Hmm all that seems like an overkill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
