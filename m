Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id BC0936B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:53:45 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id t10so6083663eei.41
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:53:44 -0700 (PDT)
Date: Fri, 12 Jul 2013 10:53:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: boot tracing
Message-ID: <20130712085341.GC4328@gmail.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
 <20130712084712.GD24008@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712084712.GD24008@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Robin Holt <holt@sgi.com>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Borislav Petkov <bp@alien8.de> wrote:

> On Fri, Jul 12, 2013 at 10:27:56AM +0200, Ingo Molnar wrote:
> > Robert Richter and Boris Petkov are working on 'persistent events'
> > support for perf, which will eventually allow boot time profiling -
> > I'm not sure if the patches and the tooling support is ready enough
> > yet for your purposes.
> 
> Nope, not yet but we're getting there.
> 
> > Robert, Boris, the following workflow would be pretty intuitive:
> > 
> >  - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB
> 
> What does perf=boot mean? I assume boot tracing.

In this case it would mean boot profiling - i.e. a cycles hardware-PMU 
event collecting into a perf trace buffer as usual.

Essentially a 'perf record -a' work-alike, just one that gets activated as 
early as practical, and which would allow the profiling of memory 
initialization.

Now, one extra complication here is that to be able to profile buddy 
allocator this persistent event would have to work before the buddy 
allocator is active :-/ So this sort of profiling would have to use 
memblock_alloc().

Just wanted to highlight this usecase, we might eventually want to support 
it.

[ Note that this is different from boot tracing of one or more trace 
  events - but it's a conceptually pretty close cousin. ]
 
Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
