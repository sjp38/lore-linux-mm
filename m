Date: Tue, 20 Jan 2004 12:09:33 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Anomaly in Buddy bitmaps?
Message-ID: <20040120200933.GR32157@holomorphy.com>
References: <20040120195729.90088.qmail@web9706.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040120195729.90088.qmail@web9706.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2004 at 11:57:29AM -0800, Alok Mooley wrote:
> I wrote a module in kernel 2.6.0 for scanning a higher
> order block from zone_mem_map for ZONE_NORMAL &
> checking the buddy bitmaps for the same.
>        In the case of order 4, while scanning on the
> order 4 block boundaries, I found an order 4 block
> with page state 0000000001111111,where 0s represent
> free pages & 1s represent order 0 allocations. The bit
> in the order 3 bitmap corresponding to this 4th order
> block was found to be a 0,whereas this bit should have
> been a 1 as one 3rd order buddy is completely free.
> I got the same result (a 0, where a 1 should have been
> found) in another case too.
> Is this an anomaly in the buddy bitmaps? Can the buddy
> bitmaps ever be inconsistent?

This could be the result of one of the free buddies being on the
per-cpu freelists. Count those as "semi-free"; they count as allocated
as far as the buddy bitmap is concerned.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
