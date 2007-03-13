Date: Tue, 13 Mar 2007 04:47:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
Message-Id: <20070313044756.b45649ac.akpm@linux-foundation.org>
In-Reply-To: <45F68B4B.9020200@yahoo.com.au>
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com>
	<20070313005334.853559ca.akpm@linux-foundation.org>
	<45F65ADA.9010501@yahoo.com.au>
	<20070313035250.f908a50e.akpm@linux-foundation.org>
	<45F685C6.8070806@yahoo.com.au>
	<20070313041551.565891b5.akpm@linux-foundation.org>
	<45F68B4B.9020200@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 13 Mar 2007 22:30:19 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> We don't actually have to zap_pte_range the entire page table in
> order to free it (IIRC we used to have to, before the 4lpt patches).

I'm trying to remember why we ever would have needed to zero out the pagetable
pages if we're taking down the whole mm?  Maybe it's because "oh, the
arch wants to put this page into a quicklist to recycle it", which is
all rather circular.

It would be interesting to look at a) leave the page full of random garbage
if we're releasing the whole mm and b) return it straight to the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
