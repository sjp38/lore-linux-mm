From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/5] Light Fragmentation Avoidance V20: 002_usemap
Date: Wed, 16 Nov 2005 02:52:04 +0100
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie> <200511160036.54461.ak@suse.de> <Pine.LNX.4.58.0511160137540.8470@skynet>
In-Reply-To: <Pine.LNX.4.58.0511160137540.8470@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511160252.05494.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wednesday 16 November 2005 02:43, Mel Gorman wrote:

> 1. I was using a page flag, valuable commodity, thought I would get kicked
>    for it. Usemap uses 1 bit per 2^(MAX_ORDER-1) pages. Page flags uses
>    2^(MAX_ORDER-1) bits at worse case.

Why does it need multiple bits? A page can only be in one order at a
time, can't it?

> 2. Fragmentation avoidance tended to break down, very fast.

Why? The algorithm should the same, no?

> 3. When changing a block of pages from one type to another, there was no
>    fast way to make sure all pages currently allocation would end up on
>    the correct free list

If you can change the bitmap you can change as well mem_map

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
