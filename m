Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 445E66B0038
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 18:54:36 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so16090447pdj.34
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 15:54:35 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id kk6si50727597pdb.193.2014.12.28.15.54.33
        for <linux-mm@kvack.org>;
        Sun, 28 Dec 2014 15:54:34 -0800 (PST)
Date: Mon, 29 Dec 2014 08:56:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm/zpool: add name argument to create zpool
Message-ID: <20141228235637.GA27095@bbox>
References: <1419599095-4382-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1419599095-4382-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, sjennings@variantweb.net, ddstreet@ieee.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 26, 2014 at 09:04:55PM +0800, Ganesh Mahendran wrote:
> Currently the underlay of zpool: zsmalloc/zbud, do not know
> who creates them. There is not a method to let zsmalloc/zbud
> find which caller they belogs to.
> 
> Now we want to add statistics collection in zsmalloc. We need
> to name the debugfs dir for each pool created. The way suggested
> by Minchan Kim is to use a name passed by caller(such as zram)
> to create the zsmalloc pool.
>     /sys/kernel/debug/zsmalloc/zram0
> 
> This patch adds a argument *name* to zs_create_pool() and other
> related functions.
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
