Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D91726B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 18:29:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e10so296091pff.3
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 15:29:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1-v6sor159426pld.59.2018.02.27.15.29.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 15:29:48 -0800 (PST)
Date: Wed, 28 Feb 2018 08:29:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm:swap: do not check readahead flag with THP anon
Message-ID: <20180227232943.GC168047@rodete-desktop-imager.corp.google.com>
References: <20180227232611.169883-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180227232611.169883-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "Huang, Ying" <ying.huang@intel.com>

On Wed, Feb 28, 2018 at 08:26:11AM +0900, Minchan Kim wrote:
> Huang reported PG_readahead flag marked PF_NO_COMPOUND so that
> we cannot use the flag for THP page. So, we need to check first
> whether page is THP or not before using TestClearPageReadahead
> in lookup_swap_cache.
> 
> This patch fixes it.
> 
> Furthermore, swap_[cluster|vma]_readahead cannot mark PG_readahead
> for newly allocated page because the allocated page is always a
> normal page, not THP at this moment. So let's clean it up, too.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

 Link:http://lkml.kernel.org/r/874lm83zho.fsf@yhuang-dev.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
