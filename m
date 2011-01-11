Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 721296B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 09:25:43 -0500 (EST)
Received: by pzk27 with SMTP id 27so4911120pzk.14
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 06:25:38 -0800 (PST)
Date: Tue, 11 Jan 2011 23:25:28 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v3] mm: add replace_page_cache_page() function
Message-ID: <20110111142528.GF2113@barrios-desktop>
References: <E1Pcet8-0007kg-3R@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Pcet8-0007kg-3R@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 03:07:54PM +0100, Miklos Szeredi wrote:
> (resent with fixed CC list, sorry for the duplicate)
> 
> Thanks for the review.
> 
> Here's an updated patch.  Modifications since the last post:
> 
>  - don't pass gfp_mask (since it's only able to deal with GFP_KERNEL
>    anyway)
> 

I am not sure it's a good idea.
Now if we need just GFP_KERNEL, we can't make sure it in future.
Sometime we might need GFP_ATOMIC and friendd functions
(ex, add_to_page_cache_lru,add_to_page_cache_locked) already have gfp_mask.
It's a exported function so it's hard to modify it in future.

I want to keep it.
Instead of removing it, we can change mem_cgroup_prepare_migration as
getting gfp_mask.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
