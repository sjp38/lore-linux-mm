Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id BDAE439A68
	for <linux-mm@kvack.org>; Wed, 24 Apr 2002 11:20:07 -0300 (EST)
Date: Wed, 24 Apr 2002 11:20:05 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <Pine.LNX.4.33.0204241138290.1968-100000@erol>
Message-ID: <Pine.LNX.4.44L.0204241112090.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Smith <csmith@micromuse.com>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2002, Christian Smith wrote:
> On Tue, 23 Apr 2002, Rik van Riel wrote:
> >On Tue, 23 Apr 2002, Christian Smith wrote:
> >
> >> The question becomes, how much work would it be to rip out the Linux MM
> >> piece-meal, and replace it with an implementation of UVM?
> >
> >I doubt we want the Mach pmap layer.
>
> Why not? It'd surely make porting to new architecures easier (not that
> I've tried it either way, mind)

You really need to read the pmap code and interface instead
of repeating the statements made by other people. Have you
ever taken a close look at the overhead implicit in the pmap
layer ?


> interface. Pmap can hide the differences between forward mapping page
> table, TLB or inverted page table lookups, can do SMP TLB shootdown
> transparently. If not the Mach pmap layer, then surely another pmap-like
> layer would be beneficial.

Then how about the Linux pmap layer ?

The datastructure is a radix tree, which happens to map 1 to 1
with the MMU on most architectures. On architectures that don't
have forward page tables Linux fills in the hardware's translation
tables with data from those radix trees.


> It can handle sparse address space management without the hackery of
> n-level page tables, where a couple of years ago, 3 levels was enough for
> anyone, but now we're not so sure.
>
> The n-level page table doesn't fit in with a high level, platform
> independant MM, and doesn't easily work for all classes of low level MMU.
> It doesn't really scale up or down.

Do you have any arguments or are you just repeating what you
read somewhere else ?

Just think about it for a second ... the radix tree structure
of page tables are as good a datastructure as any other.

The mythical "sparse mappings" seem to be very rare in real
life and I'm not convinced they are a reason to change all of
our VM.


regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
