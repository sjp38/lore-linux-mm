Date: Thu, 21 Aug 2008 08:45:29 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
Message-ID: <20080821134529.GD26567@sgi.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080820113131.f032c8a2.akpm@linux-foundation.org> <20080821024240.GC23397@sgi.com> <48AD689F.6080103@linux-foundation.org> <20080821131404.GC26567@sgi.com> <48AD6B20.1080105@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AD6B20.1080105@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tokunaga.keiich@jp.fujitsu.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 21, 2008 at 08:18:24AM -0500, Christoph Lameter wrote:
> Robin Holt wrote:
> 
> >> We removed this code because it frees a page before the TLB flush has been
> >> performed. This code segment was the reason that quicklists were not accepted
> >> for x86.
> > 
> > How could we do this.  It was a _HUGE_ problem on altix boxes.  When you
> > started a jobs with a large number of MPI ranks, they would all start
> > from the shepherd process on a single node and the children would
> > migrate to a different cpu.  Unless subsequent jobs used enough memory
> > to flush those remote quicklists, we would end up with a depleted node
> > that never reclaimed.
> 
> Well I tried to get the quicklist stuff resolved at SGI multiple times last
> year when the early free before flush was discovered but there did not seem to
> be much interest at that point, so we dropped it.

Well, now that you dope slap me, I vaguely remember this.  I also seem
to recall being very busy with other stuff and convincing myself that a
proper resolution would magically appear.  Argh.

Sorry,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
