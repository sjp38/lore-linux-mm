Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 451866B007B
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 13:16:50 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq2so781807pbb.34
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 10:16:49 -0800 (PST)
Received: from psmtp.com ([74.125.245.178])
        by mx.google.com with SMTP id gg8si3876005pac.2.2013.11.13.10.16.46
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 10:16:47 -0800 (PST)
Date: Wed, 13 Nov 2013 19:16:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131113181623.GS21461@twins.programming.kicks-ass.net>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
 <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
 <20131104073640.GF13030@gmail.com>
 <1384143129.6940.32.camel@buesod1.americas.hpqcorp.net>
 <CANN689Eauq+DHQrn8Wr=VU-PFGDOELz6HTabGDGERdDfeOK_UQ@mail.gmail.com>
 <20131111120421.GB21291@gmail.com>
 <1384202848.6940.59.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384202848.6940.59.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Mon, Nov 11, 2013 at 12:47:28PM -0800, Davidlohr Bueso wrote:
> On Mon, 2013-11-11 at 13:04 +0100, Ingo Molnar wrote:
> in find_vma() but the cost of maintaining it comes free. I just ran into
> a similar idea from 2 years ago:
> http://lkml.indiana.edu/hypermail/linux/kernel/1112.1/01352.html

Here's one from 2007:

http://programming.kicks-ass.net/kernel-patches/futex-vma-cache/vma_cache.patch

and I'm very sure Nick Piggin had one even older :-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
