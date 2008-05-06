Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m46JBtxf031354
	for <linux-mm@kvack.org>; Tue, 6 May 2008 15:11:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m46JBtcN128078
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:11:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m46JBsKV013768
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:11:54 -0600
Date: Tue, 6 May 2008 12:11:53 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080506191153.GB8369@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 07:53:23AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 6 May 2008, Nick Piggin wrote:
> > 
> > Right. As the comment says, the x86 stuff is kind of a "reference"
> > implementation, although if you prefer it isn't there, then I I can
> > easily just make it alpha only.
> 
> If there really was a point in teaching people about 
> "read_barrier_depends()", I'd agree that it's probably good to have it as 
> a reference in the x86 implementation.
> 
> But since alpha is the only one that needs it, and is likely to remain so, 
> it's not like we ever want to copy that code to anything else, and it 
> really is better to make it alpha-only if the code is so much uglier.
> 
> Maybe just a comment?
> 
> As to the ACCESS_ONCE() thing, thinking about it some more, I doubt it 
> really matters. We're never going to change pgd anyway, so who cares if we 
> access it once or a hundred times?

If we are never going to change mm->pgd, then why do we need the
smp_read_barrier_depends()?  Is this handling the initialization
case or some such?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
