Date: Mon, 20 Dec 2004 19:56:36 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
 <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Linus Torvalds wrote:
> 
> (It may be _possible_ to avoid the warnings by just making "pud_t" and
> "pmd_t" be the same type for such architectures, and just allowing
> _mixing_ of three-level and four-level accesses.  I have to say that I 
> consider that pretty borderline programming practice though).

Actually, I notice that this is exactly what you did, sorry for not being 
more careful about reading your defines.

Thinking some more about it, I don't much like the "mixing" of 3-level and
4-level things, but since the only downside is a lack of type-safety for
the 4-level case (ie you can get it wrong without getting any warning),
and since that type safety _does_ exist in the case where the four levels 
are actually used, I think it's ok. 

It would be bad if the architecture that supported 4level page tables was
really rare and broken (so that mistakes would happen and not get noticed
for a while), but I suspect x86-64 by now is probably the second- or
third-most used architecture, so it's not like the lack of type safety on 
other architectures where it doesn't matter would be a huge maintenance 
problem.

Color me convinced. 

Nick, can you see if such a patch is possible? I'll test ppc64 still 
working..

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
