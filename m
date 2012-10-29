Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DCFFC6B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 22:06:34 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:12:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] minor clean-up and optimize highmem related code
Message-ID: <20121029021219.GK15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351451576-2611-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Hi Joonsoo,

On Mon, Oct 29, 2012 at 04:12:51AM +0900, Joonsoo Kim wrote:
> This patchset clean-up and optimize highmem related code.
> 
> [1] is just clean-up and doesn't introduce any functional change.
> [2-3] are for clean-up and optimization.
> These eliminate an useless lock opearation and list management.
> [4-5] is for optimization related to flush_all_zero_pkmaps().
> 
> Joonsoo Kim (5):
>   mm, highmem: use PKMAP_NR() to calculate an index of pkmap
>   mm, highmem: remove useless pool_lock
>   mm, highmem: remove page_address_pool list
>   mm, highmem: makes flush_all_zero_pkmaps() return index of last
>     flushed entry
>   mm, highmem: get virtual address of the page using PKMAP_ADDR()

This patchset looks awesome to me.
If you have a plan to respin, please CCed Peter.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
