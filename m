Date: Fri, 2 Aug 2002 00:09:40 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] reduce usage of mem_map
Message-ID: <20020802070940.GA29537@holomorphy.com>
References: <869105998.1028245087@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <869105998.1028245087@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <fletch@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

jn Thu, Aug 01, 2002 at 11:38:07PM -0700, Martin J. Bligh wrote:
> I've tried to cut down the usage of mem_map somewhat.
> There's already macros to do the conversion between
> pfns to pages, and it doesn't work the way they've
> embedded it for discontigmem systems. Comments?
> Please don't apply - not tested yet ;-)
> M.

mem_map should be eliminated anyway. The concept is a legacy interface
for indexing into the older contiguous core map. The only pseudo-useful
thing it does is creating some kind of base address for address
calculation in page_to_pfn() etc., not that they're any kind of
performance-critical bit of the kernel. Those kinds of things can
circumvent the core VM without any significant ugliness impact.
Worse comes to worse, just do Roman Zippel's thing and shove the
page_address() bits into arch code where they'd belong if arches weren't
forcing us to keep ->virtual all the time (necessitating core control).

In the meantime, the necessity of laying out the pageframe maps in such
a manner that indexing from mem_map is sort of valid is an irritating
constraint not satisfiable without virtual remapping tricks and/or
MAP_NR_DENSE() on many platforms. Kill it. Kill it dead.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
