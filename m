Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 24C9E6B004A
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 07:03:02 -0500 (EST)
Date: Thu, 11 Nov 2010 20:02:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
Message-ID: <20101111120255.GA7654@localhost>
References: <20101111075455.GA10210@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101111075455.GA10210@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 06:54:55PM +1100, Nick Piggin wrote:
> Testing ->mapping and ->index without a ref is not stable as the page
> may have been reused at this point.
> 
> Signed-off-by: Nick Piggin <npiggin@kernel.dk>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Just out of curious, did you catch it by code review or tests?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
