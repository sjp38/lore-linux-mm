Date: Mon, 26 Mar 2007 18:22:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <20070327010624.GA2986@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0703261817160.14048@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
 <20070323222133.f17090cf.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com>
 <20070326102651.6d59207b.akpm@linux-foundation.org> <20070327010624.GA2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Mar 2007, William Lee Irwin III wrote:

> Not that clameter really needs my help, but I agree with his position
> on several fronts, and advocate accordingly, so here is where I'm at.

Yes thank you. I386 is not my field, I have no interest per se in 
improving i386 performance and without your help I would have to drop this 
and keep the special casing in SLUB for i386. Generic tlb.h changes may 
also help to introduce quicklists to x86_64. The current quicklist patches 
can only work on higher levels due to the freeing of ptes via 
tlb_remove_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
