Date: Sat, 20 Nov 2004 09:14:11 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: page fault scalability patch V11 [0/7]: overview
In-Reply-To: <1834180000.1100969975@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0411200911540.20993@ppc970.osdl.org>
References: <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <20041120020306.GA2714@holomorphy.com>
 <419EBBE0.4010303@yahoo.com.au> <20041120035510.GH2714@holomorphy.com>
 <419EC205.5030604@yahoo.com.au> <20041120042340.GJ2714@holomorphy.com>
 <419EC829.4040704@yahoo.com.au> <20041120053802.GL2714@holomorphy.com>
 <419EDB21.3070707@yahoo.com.au> <20041120062341.GM2714@holomorphy.com>
 <419EE911.20205@yahoo.com.au> <20041119225701.0279f846.akpm@osdl.org>
 <419EEE7F.3070509@yahoo.com.au> <1834180000.1100969975@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, wli@holomorphy.com, clameter@sgi.com, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sat, 20 Nov 2004, Martin J. Bligh wrote:
> 
> Per thread seems much nicer to me - mainly because it degrades cleanly to 
> a single counter for 99% of processes, which are single threaded.

I will pretty much guarantee that if you put the per-thread patches next
to some abomination with per-cpu allocation for each mm, the choice will
be clear. Especially if the per-cpu/per-mm thing tries to avoid false
cacheline sharing, which sounds really "interesting" in itself.

And without the cacheline sharing avoidance, what's the point of this 
again? It sure wasn't to make the code simpler. It was about performance 
and scalability.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
