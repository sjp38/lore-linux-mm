Date: Mon, 24 Jan 2005 09:49:54 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Query on remap_pfn_range compatibility
Message-ID: <20050124174954.GF10843@holomorphy.com>
References: <OF3F115AC8.F271AB73-ON86256F93.005BCD86@raytheon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF3F115AC8.F271AB73-ON86256F93.005BCD86@raytheon.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@raytheon.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2005 at 10:54:22AM -0600, Mark_H_Johnson@raytheon.com wrote:
> I read the messages on lkml from September 2004 about the introduction of
> remap_pfn_range and have a question related to coding for it. What do you
> recommend for driver coding to be compatible with these functions
> (remap_page_range, remap_pfn_range)?
> For example, I see at least two (or three) combination I need to address:
>  - 2.4 (with remap_page_range) OR 2.6.x (with remap_page_range)
>  - 2.6.x-mm (with remap_pfn_range)
> Is there some symbol or #ifdef value I can depend on to determine which
> function I should be calling (and the value to pass in)?

Not sure. One on kernel version being <= 2.6.10 would probably serve
your purposes, though it's not particularly well thought of. I suspect
people would suggest splitting up the codebase instead of sharing it
between 2.4.x and 2.6.x, where I've no idea how well that sits with you.

I vaguely suspected something like this would happen, but there were
serious and legitimate concerns about new usage of the 32-bit unsafe
methods being reintroduced, so at some point the old hook had to go.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
