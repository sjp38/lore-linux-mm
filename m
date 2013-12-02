Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7B15B6B003C
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:10:02 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so4844907qaq.15
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:10:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o8si33813697qec.60.2013.12.02.12.10.00
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:10:01 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:50 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014990-md6lddie-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-7-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/9] mm/rmap: use rmap_walk() in try_to_unmap()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:43PM +0900, Joonsoo Kim wrote:
> Now, we have an infrastructure in rmap_walk() to handle difference
> from variants of rmap traversing functions.
> 
> So, just use it in try_to_unmap().
> 
> In this patch, I change following things.
> 
> 1. enable rmap_walk() if !CONFIG_MIGRATION.
> 2. mechanical change to use rmap_walk() in try_to_unmap().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
