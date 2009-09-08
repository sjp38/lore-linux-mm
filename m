Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94C246B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:27:18 -0400 (EDT)
Subject: Re: [rfc] lru_add_drain_all() vs isolation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com>
	 <1252405209.7746.38.camel@twins>
	 <20090908193712.0CCF.A69D9226@jp.fujitsu.com>
	 <1252411520.7746.68.camel@twins>
	 <alpine.DEB.1.10.0909081000100.15723@V090114053VZO-1>
	 <1252419602.7746.73.camel@twins>
	 <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
Content-Type: text/plain
Date: Tue, 08 Sep 2009 17:27:16 +0200
Message-Id: <1252423637.7746.99.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-08 at 11:22 -0400, Christoph Lameter wrote:
> On Tue, 8 Sep 2009, Peter Zijlstra wrote:
> 
> > There is _no_ functional difference between before and after, except
> > less wakeups on cpus that don't have any __lru_cache_add activity.
> >
> > If there's pages on the per cpu lru_add_pvecs list it will be present in
> > the mask and will be send a drain request. If its not, then it won't be
> > send.
> 
> Ok I see.
> 
> A global cpu mask like this will cause cacheline bouncing. After all this
> is a hot cpu path. Maybe do not set the bit if its already set
> (which may be very frequent)? Then add some benchmarks to show that it
> does not cause a regression on a 16p box (Nehalem) or so?

Yeah, testing the bit before poking at is sounds like a good plan.

Unless someone feels inclined to finish this and audit the kernel for
more such places, I'll stick it on the ever growing todo pile.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
