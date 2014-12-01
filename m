Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 267A56B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:29:31 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so9867533pac.22
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 16:29:30 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gy1si26383536pbd.94.2014.11.30.16.29.28
        for <linux-mm@kvack.org>;
        Sun, 30 Nov 2014 16:29:29 -0800 (PST)
Date: Mon, 1 Dec 2014 09:29:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm/zsmalloc: allocate exactly size of struct zs_pool
Message-ID: <20141201002948.GC11340@bbox>
References: <1417260235-32053-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1417260235-32053-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, ddstreet@ieee.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 29, 2014 at 07:23:55PM +0800, Ganesh Mahendran wrote:
> In zs_create_pool(), we allocate memory more then sizeof(struct zs_pool)
>   ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> 
> This patch allocate memory of exactly needed size.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
