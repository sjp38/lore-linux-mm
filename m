Date: Mon, 20 Dec 2004 10:15:42 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
In-Reply-To: <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.58.0412201011230.4112@ppc970.osdl.org>
References: <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au>
 <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
 <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au>
 <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
 <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org>
 <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Linus Torvalds wrote:
> 
> I would suggest that if you want unit-at-a-time, you make it a config 
> option, and you mark it very clearly as requiring a new enough compiler 
> that it's worth it and stable. That way if people have problems, we can 
> ask them "did you have unit-at-a-time enabled?" and see if the problem 
> goes away.

Btw, if you do this, I'd also suggest checking out exactly when gcc
started to do things right - not just "praying" about which version of gcc
is recent enough. Exactly so that the KConfig help message can say "if
your version of gcc is more recent than 3.3.4" rather than "if you have
some unspecified recent compiler".

The thing is, individual big stack users are fairly easy to find. But a 
chain where a few functions grew the stack a bit more, and the combined 
stack usage became big is harder to see.

I guess I could try to make sparse generate soem call-chain information 
(need to take function pointer structure usage into account to make it 
really useful, since a lot of the callchains are through the VFS and MM 
pointers)

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
