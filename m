Date: Tue, 6 Dec 2005 11:36:43 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
In-Reply-To: <20051206192603.GX11190@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0512061131500.19637@schroedinger.engr.sgi.com>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
 <20051206183524.GU11190@wotan.suse.de> <Pine.LNX.4.62.0512061105220.19475@schroedinger.engr.sgi.com>
 <20051206192603.GX11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Dec 2005, Andi Kleen wrote:

> > Yuck. That code uses atomic operations and is not aware of atomic64_t.
> Hmm? What code are you looking at? 
include/asm-generic/local.h. this is the default right? And 
include/asm-ia64/local.h.
 
> At least i386/x86-64/generic don't use any atomic operations, just
> normal non atomic on bus but atomic for interrupts local rmw.

inc/dec are atomic by default on x86_64?
 
> Do you actually need 64bit? 

32 bit limits us in the worst case to 8 Terabytes of RAM (assuming a very 
small page size of 4k and 31 bit available for an atomic variable 
[sparc]). SGI already has installations with 15 Terabytes of RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
