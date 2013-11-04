Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F20B26B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 09:20:08 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so6959899pab.18
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 06:20:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.203])
        by mx.google.com with SMTP id ph6si10596684pbb.217.2013.11.04.06.20.07
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 06:20:07 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id cb5so575266wib.7
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 06:20:05 -0800 (PST)
Date: Mon, 4 Nov 2013 15:20:02 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104142001.GE9299@localhost.localdomain>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
 <20131104070500.GE13030@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131104070500.GE13030@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Jiri Olsa <jolsa@redhat.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Nov 04, 2013 at 08:05:00AM +0100, Ingo Molnar wrote:
> 
> * Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > Btw, do you suggest using a high level tool such as perf for getting 
> > this data or sprinkling get_cycles() in find_vma() -- I'd think that the 
> > first isn't fine grained enough, while the later will probably variate a 
> > lot from run to run but the ratio should be rather constant.
> 
> LOL - I guess I should have read your mail before replying to it ;-)
> 
> Yes, I think get_cycles() works better in this case - not due to 
> granularity (perf stat will report cycle granular just fine), but due to 
> the size of the critical path you'll be measuring. You really want to 
> extract the delta, because it's probably so much smaller than the overhead 
> of the workload itself.
> 
> [ We still don't have good 'measure overhead from instruction X to 
>   instruction Y' delta measurement infrastructure in perf yet, although
>   Frederic is working on such a trigger/delta facility AFAIK. ]

Yep, in fact Jiri took it over and he's still working on it. But yeah, once
that get merged, we should be able to measure instructions or cycles inside
any user or kernel function through kprobes/uprobes or function graph tracer.

> 
> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
