Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E71E60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 06:50:09 -0500 (EST)
Date: Tue, 8 Dec 2009 21:48:03 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: hwpoison madvise code
Message-ID: <20091208104803.GC3511@nick>
References: <20091208112412.GA6038@wotan.suse.de> <20091208112623.GX18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091208112623.GX18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 08, 2009 at 12:26:23PM +0100, Andi Kleen wrote:
> On Tue, Dec 08, 2009 at 12:24:12PM +0100, Nick Piggin wrote:
> > Hi,
> > 
> > Seems like the madvise hwpoison code is ugly and buggy, not to
> > put too fine a point on it :)
> > 
> > Ugly: it should have just followed the same pattern as the other
> > transient advices.
> 
> That wouldn't work.

Of course it will. You may have no need to be given the actual
vma, but that's no big deal. Much better than making up your own
way of doing things.

 
> > Buggy: it doesn't take mmap_sem. If it followed the pattern, it
> > wouldn't have had this bug.
> 
> get_user_pages takes mmap_sem if needed.

On the contrary it is clearly documented as requiring mmap_sem.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
