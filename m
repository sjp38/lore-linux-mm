Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C97C06B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 00:23:05 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so34452920pad.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:23:05 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id cy4si8426982pdb.172.2015.01.28.21.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 21:23:05 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so34497836pab.0
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:23:04 -0800 (PST)
Date: Thu, 29 Jan 2015 14:22:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zram: free meta table in zram_meta_free
Message-ID: <20150129052254.GA25462@blaptop>
References: <1421711028-5553-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421711028-5553-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Jan 20, 2015 at 07:43:47AM +0800, Ganesh Mahendran wrote:
> zram_meta_alloc() and zram_meta_free() are a pair.
> In zram_meta_alloc(), meta table is allocated. So it it better to free
> it in zram_meta_free().
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
