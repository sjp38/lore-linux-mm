Subject: Re: [PATCH] mm: exempt pcp alloc from watermarks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4510086C.4020101@yahoo.com.au>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	 <20060914220011.2be9100a.akpm@osdl.org>
	 <20060914234926.9b58fd77.pj@sgi.com>
	 <20060915002325.bffe27d1.akpm@osdl.org>
	 <20060915012810.81d9b0e3.akpm@osdl.org>
	 <20060915203816.fd260a0b.pj@sgi.com>
	 <20060915214822.1c15c2cb.akpm@osdl.org>
	 <20060916043036.72d47c90.pj@sgi.com>
	 <20060916081846.e77c0f89.akpm@osdl.org>
	 <20060917022834.9d56468a.pj@sgi.com>	<450D1A94.7020100@yahoo.com.au>
	 <20060917041525.4ddbd6fa.pj@sgi.com>	<450D434B.4080702@yahoo.com.au>
	 <20060917061922.45695dcb.pj@sgi.com>  <450D5310.50004@yahoo.com.au>
	 <1158583495.23551.53.camel@twins>  <45100028.90109@yahoo.com.au>
	 <1158677483.23551.59.camel@twins>  <4510086C.4020101@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 19 Sep 2006 17:05:24 +0200
Message-Id: <1158678324.23551.62.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-20 at 01:10 +1000, Nick Piggin wrote:
> Peter Zijlstra wrote:
> > On Wed, 2006-09-20 at 00:35 +1000, Nick Piggin wrote:
> > 
> 
> >>Thanks for the patch! I have a slight preference for the following
> >>version, which speculatively tests pcp->count without disabling
> >>interrupts (the chance of being preempted or scheduled in this
> >>window is basically the same as the chance of being preempted after
> >>checking watermarks). What do you think?
> > 
> > 
> > The race here allows to wrongly bypass the watermark check. My version
> > raced the other way about, where you could find a non empty pcp where an
> > empty one was otherwise expected.
> 
> I really doubt it matters. You could be preempted after that check
> anyway, and by the time you return the previous watermark check is
> meaningless.
> 
> If we really want to be strict about watermark checks, it has to be
> done with the zone lock held, no other option. I doubt anybody
> bothered, because the watermarks (even PF_MEMALLOC pool) are all
> heuristics anyway and it is a better idea to keep fastpath code fast.

Yes, you're absolutely right. I forgot to look at the bigger picture.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
