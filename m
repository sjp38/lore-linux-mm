Date: Thu, 1 May 2008 12:29:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] SLQB v2
In-Reply-To: <20080501015418.GC15179@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805011226410.8738@schroedinger.engr.sgi.com>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu>
 <20080501015418.GC15179@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 May 2008, Nick Piggin wrote:

> > A small question for SLUB devs, would you accept a patch that does
> > a similar thing by creating 'slub_page' instead of stuffing slub 
> > elements (freelist, inuse, ..) in 'mm_types::struct page' unions ?
> 
> I'd like to see that. I have a patch for SLUB, actually.

We could do that but then how do we make sure that both definitions stay 
in sync? So far I have thought that it is clearer if we have one def 
that shows how objects are overloaded.

There is also the overloading of page flags that is now done separately 
in SLUB. I wonder if that needs to be moved into page-flags.h? Would 
clarify how page flags are overloaded.

If someone inspects the contents of a page struct via debug then it would 
help if all the possible uses are in one place. If the stuff in tucked 
away in mm/sl?b.c then its difficult to find.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
