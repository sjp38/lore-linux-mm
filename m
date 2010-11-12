Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 499C76B00AF
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 00:48:04 -0500 (EST)
Date: Fri, 12 Nov 2010 16:48:00 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
Message-ID: <20101112054800.GA3332@amd>
References: <20101111075455.GA10210@amd>
 <20101111120255.GA7654@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101111120255.GA7654@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 08:02:55PM +0800, Wu Fengguang wrote:
> On Thu, Nov 11, 2010 at 06:54:55PM +1100, Nick Piggin wrote:
> > Testing ->mapping and ->index without a ref is not stable as the page
> > may have been reused at this point.
> > 
> > Signed-off-by: Nick Piggin <npiggin@kernel.dk>
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Just out of curious, did you catch it by code review or tests?

It was just review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
