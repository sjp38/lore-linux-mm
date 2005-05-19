Date: Wed, 18 May 2005 19:47:57 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
In-Reply-To: <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.58.0505181946300.2322@ppc970.osdl.org>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
 <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org>
 <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 18 May 2005, Rik van Riel wrote:
>
> On Wed, 18 May 2005, Linus Torvalds wrote:
> 
> > Why not just change the "addr >= len" test into "addr > len" and be done 
> > with it?
> 
> If you're fine with not catching dereferences of a struct
> member further than PAGE_SIZE into a struct when the struct
> pointer is NULL, sure ...

I'm certainly ok with that, especially since it should never be a problem
in practice (ie the virtual memory map getting so full that we even get to
these low allocations should be basically something that never happens
under normal load).

However, it would be good to have even the trivial patch tested. 
Especially since what it tries to fix is a total corner-case in the first 
place..

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
