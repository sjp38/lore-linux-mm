Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id A8D7E6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:09:12 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so11619423qeb.0
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:09:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lh4si25213854qeb.144.2013.12.02.12.09.09
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:09:10 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:02 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014942-zgaujzhz-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-2-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/9] mm/rmap: recompute pgoff for huge page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:38PM +0900, Joonsoo Kim wrote:
> We have to recompute pgoff if the given page is huge, since result based
> on HPAGE_SIZE is not approapriate for scanning the vma interval tree, as
> shown by commit 36e4f20af833 ("hugetlb: do not use vma_hugecache_offset()
> for vma_prio_tree_foreach") and commit 369a713e ("rmap: recompute pgoff
> for unmapping huge page").
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
