Date: Mon, 22 Jul 2002 10:34:07 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
In-Reply-To: <3D3BAA5B.E3C100A6@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207221029590.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Jul 2002, Andrew Morton wrote:
> "Martin J. Bligh" wrote:

> > These large NUMA machines should actually be rmap's glory day in the
> > sun.
>
> "should be".  Sigh.  Be nice to see an "is" one day ;)

You asked for a "minimal rmap" patch and you got it. ;)

Bill and I actually have code for many of the things listed
but we haven't submitted it yet exactly because everybody
wanted the code merged in small, manageable chunks.

> Do you think that large pages alone would be enough to allow us
> to leave pte_chains (and page tables?) in ZONE_NORMAL, or would
> shared pagetables also be needed?

Large pages should reduce the page table overhead by a factor
of 1024 (or 512 for PAE) and have the same alignment restrictions
that shared page tables have.

OTOH, shared page tables would allow us to map in chunks smaller
than 4MB ... but at what seems like a pretty horrible locking and
accounting complexity, unless somebody comes up with a smart trick.

Apart from both of these we'll also need code to garbage collect
empty page tables so users can't clog up memory by mmaping a page
every 4 MB ;)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
