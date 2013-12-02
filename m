Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id 72D0C6B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 15:09:35 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id 2so14124444qeb.30
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 12:09:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y5si485109qat.137.2013.12.02.12.09.32
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 12:09:34 -0800 (PST)
Date: Mon, 02 Dec 2013 15:09:24 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386014964-wqgf1m0u-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1385624926-28883-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-4-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/9] mm/rmap: factor lock function out of rmap_walk_anon()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, Nov 28, 2013 at 04:48:40PM +0900, Joonsoo Kim wrote:
> When we traverse anon_vma, we need to take a read-side anon_lock.
> But there is subtle difference in the situation so that we can't use
> same method to take a lock in each cases. Therefore, we need to make
> rmap_walk_anon() taking difference lock function.
> 
> This patch is the first step, factoring lock function for anon_lock out
> of rmap_walk_anon(). It will be used in case of removing migration entry
> and in default of rmap_walk_anon().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
