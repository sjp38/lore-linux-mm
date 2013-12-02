Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFC06B003A
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:10:02 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so13614334qen.5
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:10:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lc9si28365068qeb.100.2013.12.02.12.10.00
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:10:01 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:55 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014995-36kc4vmm-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-8-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-8-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 7/9] mm/rmap: use rmap_walk() in try_to_munlock()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:44PM +0900, Joonsoo Kim wrote:
> Now, we have an infrastructure in rmap_walk() to handle difference
> from variants of rmap traversing functions.
> 
> So, just use it in try_to_munlock().
> 
> In this patch, I change following things.
> 
> 1. remove some variants of rmap traversing functions.
> 	cf> try_to_unmap_ksm, try_to_unmap_anon, try_to_unmap_file
> 2. mechanical change to use rmap_walk() in try_to_munlock().
> 3. copy and paste comments.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
