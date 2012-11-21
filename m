Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D9FB76B0070
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:39:21 -0500 (EST)
Date: Wed, 21 Nov 2012 11:39:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 3/3] man-pages: Add man page for vmpressure_fd(2)
Message-Id: <20121121113920.0f0672b1.akpm@linux-foundation.org>
In-Reply-To: <20121121150149.GE8218@suse.de>
References: <20121107105348.GA25549@lizard>
	<20121107110152.GC30462@lizard>
	<20121119215211.6370ac3b.akpm@linux-foundation.org>
	<20121120062400.GA9468@lizard>
	<alpine.DEB.2.00.1211201004390.4200@chino.kir.corp.google.com>
	<20121121150149.GE8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, 21 Nov 2012 15:01:50 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Nov 20, 2012 at 10:12:28AM -0800, David Rientjes wrote:
> > On Mon, 19 Nov 2012, Anton Vorontsov wrote:
> > 
> > > We try to make userland freeing resources when the system becomes low on
> > > memory. Once we're short on memory, sometimes it's better to discard
> > > (free) data, rather than let the kernel to drain file caches or even start
> > > swapping.
> > > 
> > 
> > To add another usecase: its possible to modify our version of malloc (or 
> > any malloc) so that memory that is free()'d can be released back to the 
> > kernel only when necessary, i.e. when keeping the extra memory around 
> > starts to have a detremental effect on the system, memcg, or cpuset.  When 
> > there is an abundance of memory available such that allocations need not 
> > defragment or reclaim memory to be allocated, it can improve performance 
> > to keep a memory arena from which to allocate from immediately without 
> > calling the kernel.
> > 
> 
> A potential third use case is a variation of the first for batch systems. If
> it's running low priority tasks and a high priority task starts that
> results in memory pressure then the job scheduler may decide to move the
> low priority jobs elsewhere (or cancel them entirely).
> 
> A similar use case is monitoring systems running high priority workloads
> that should never swap. It can be easily detected if the system starts
> swapping but a pressure notification might act as an early warning system
> that something is happening on the system that might cause the primary
> workload to start swapping.

I hope Anton's writing all of this down ;)


The proposed API bugs me a bit.  It seems simplistic.  I need to have a
quality think about this.  Maybe the result of that think will be to
suggest an interface which can be extended in a back-compatible fashion
later on, if/when the simplistic nature becomes a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
