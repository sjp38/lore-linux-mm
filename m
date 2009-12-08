Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8738960021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 07:07:12 -0500 (EST)
Date: Tue, 8 Dec 2009 22:05:07 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: hwpoison madvise code
Message-ID: <20091208110507.GF3511@nick>
References: <20091208112412.GA6038@wotan.suse.de> <20091208112623.GX18989@one.firstfloor.org> <20091208104803.GC3511@nick> <20091208120156.GZ18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091208120156.GZ18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 08, 2009 at 01:01:56PM +0100, Andi Kleen wrote:
> > > > Buggy: it doesn't take mmap_sem. If it followed the pattern, it
> > > > wouldn't have had this bug.
> > > 
> > > get_user_pages takes mmap_sem if needed.
> > 
> > On the contrary it is clearly documented as requiring mmap_sem.
> 
> True, I forgot about that. I think at some point I had gup_fast
> in there, I'll just switch back to that. Thanks for the kind note.

My pleasure :) 

> BTW looking over the tree I find at least one other caller that doesn't
> hold it, like futex.c:fault_in_user_writeable. I'll send a separate
> patch for t hat.

Nasty. Good catch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
