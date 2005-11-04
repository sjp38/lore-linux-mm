Date: Fri, 4 Nov 2005 16:53:17 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051104155317.GA7281@elte.hu>
References: <20051104010021.4180A184531@thermo.lanl.gov> <Pine.LNX.4.64.0511032105110.27915@g5.osdl.org> <20051103221037.33ae0f53.pj@sgi.com> <20051104063820.GA19505@elte.hu> <Pine.LNX.4.64.0511040725090.27915@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0511040725090.27915@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@osdl.org> wrote:

> Boot-time option to set the hugetlb zone, yes.
> 
> Grow-or-shrink, probably not. Not in practice after bootup on any 
> machine that is less than idle.
> 
> The zones have to be pretty big to make any sense. You don't just grow 
> them or shrink them - they'd be on the order of tens of megabytes to 
> gigabytes. In other words, sized big enough that you will _not_ be 
> able to create them on demand, except perhaps right after boot.

i think the current hugepages=<N> boot option could transparently be 
morphed into a 'separate zone' approach, and /proc/sys/vm/nr_hugepages 
would just refuse to change (or would go away altogether). Dynamically 
growing zones seem like a lot of trouble, without much gain. [ OTOH 
hugepages= parameter unit should be changed from the current 'number of 
hugepages' to plain RAM metrics - megabytes/gigabytes. ]

that would solve two problems: any 'zone VM statistics skewing effect' 
of the current hugetlbs (which is a preallocated list of really large 
pages) would go away, and the hugetlb zone could potentially be utilized 
for easily freeable objects.

this would already be alot more flexible that what we have: the hugetlb 
area would not be 'lost' altogether, like now. Once we are at this stage 
we can see how usable it is in practice. I strongly suspect it will 
cover most of the HPC uses.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
