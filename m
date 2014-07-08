Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 262276B0031
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 23:54:53 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so6584915pab.30
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 20:54:52 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id xj7si42520400pbc.33.2014.07.07.20.54.50
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 20:54:51 -0700 (PDT)
Message-ID: <53BB6B64.1080807@cn.fujitsu.com>
Date: Tue, 8 Jul 2014 11:54:12 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 1/7] mm: support madvise(MADV_FREE)
References: <1404694438-10272-1-git-send-email-minchan@kernel.org> <1404694438-10272-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1404694438-10272-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi Minchan,

On 07/07/2014 08:53 AM, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS
> already have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than
> swapping out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace
> without another additional overhead(ex, page fault + allocation
> + zeroing).
> 
> How to work is following as.
> 
> When madvise syscall is called, VM clears dirty bit of ptes of
> the range. 

This should be updated because the implementation has been changed.
It also remove the page from the swapcache if it is.

Thank you for your effort!

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
