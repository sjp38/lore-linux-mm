Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9BC6B003D
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:10:14 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id o15so4841962qap.4
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:10:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m6si56366390qey.141.2013.12.02.12.10.13
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:10:13 -0800 (PST)
Date: Mon, 02 Dec 2013 15:10:00 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386015000-duz3i1h4-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-9-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-9-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 8/9] mm/rmap: use rmap_walk() in page_referenced()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:45PM +0900, Joonsoo Kim wrote:
> Now, we have an infrastructure in rmap_walk() to handle difference
> from variants of rmap traversing functions.
> 
> So, just use it in page_referenced().
> 
> In this patch, I change following things.
> 
> 1. remove some variants of rmap traversing functions.
> 	cf> page_referenced_ksm, page_referenced_anon,
> 	page_referenced_file
> 2. introduce new struct page_referenced_arg and pass it to
> page_referenced_one(), main function of rmap_walk, in order to
> count reference, to store vm_flags and to check finish condition.
> 3. mechanical change to use rmap_walk() in page_referenced().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
