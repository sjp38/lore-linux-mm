Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6846B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 19:02:10 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so13840675pab.26
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 16:02:10 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id q2si19910770pdf.63.2014.11.12.16.02.07
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 16:02:08 -0800 (PST)
Date: Thu, 13 Nov 2014 09:02:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
Message-ID: <20141113000216.GA1074@bbox>
References: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, weijie.yang@samsung.com, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 12, 2014 at 10:37:18PM +0800, Mahendran Ganesh wrote:
> In struct zram_table_entry, the element *value* contains obj size and
> obj zram flags. Bit 0 to bit (ZRAM_FLAG_SHIFT - 1) represent obj size,
> and bit ZRAM_FLAG_SHIFT to the highest bit of unsigned long represent obj
> zram_flags. So the first zram flag(ZRAM_ZERO) should be from ZRAM_FLAG_SHIFT
> instead of (ZRAM_FLAG_SHIFT + 1).
> 
> This patch fixes this issue.
> 
> Also this patch fixes a typo, "page in now accessed" -> "page is now accessed"
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

To be clear about "fixes this issue", it's not a bug but just clean up
so it doesn't change any behavior.

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
