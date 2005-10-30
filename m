Message-ID: <4364296E.1080905@yahoo.com.au>
Date: Sun, 30 Oct 2005 13:01:18 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com> <20051029184728.100e3058.pj@sgi.com>
In-Reply-To: <20051029184728.100e3058.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: "Rohit, Seth" <rohit.seth@intel.com>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> A couple more items:
>  1) Lets try for a consistent use of type "gfp_t" for gfp_mask.
>  2) The can_try_harder flag values were driving me nuts.

Please instead use a second argument 'gfp_high', which will nicely
match zone_watermark_ok, and use that consistently when converting
__alloc_pages code to use get_page_from_freelist. Ie. keep current
behaviour.

That would solve my issues with the patch.

>  3) The "inline" you added to buffered_rmqueue() blew up my compile.

How? Why? This should be solved because a future possible feature
(early allocation from pcp lists) will want inlining in order to
propogate the constant 'replenish' argument.

>  4) The return from try_to_free_pages() was put in "i" for no evident reason.
>  5) I have no clue what the replenish flag you added to buffered_rmqueue does.
> 

Slight patch mis-split I guess. For the cleanup patch, you're right,
this should be removed.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
