Date: Mon, 9 Apr 2007 11:56:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 3/4] Quicklist support for x86_64
In-Reply-To: <200704092053.05590.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704091153480.8986@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <200704092049.34317.ak@suse.de> <Pine.LNX.4.64.0704091150260.8783@schroedinger.engr.sgi.com>
 <200704092053.05590.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andi Kleen wrote:

> > Otherwise you will leak pages to the page allocator before the tlb flush 
> > occurred.
> 
> I don't get it sorry. Can you please explain in more detail?

On process teardown pages are freed via the tlb mechanism. That mechanism 
guarantees that TLBs for pages are flushed before they can be reused. We 
tie into that and put pages on quicklists. The quicklists are trimmed
after the TLB flush.

If a shrinker would indepedently free pages from the quicklists then this 
mechanism would no longer work and pages that still have a valid TLB for 
one process may be reused by other processes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
