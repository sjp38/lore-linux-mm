Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 093A96B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 23:38:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u5so1106445984pgi.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 20:38:54 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r7si78099044pgf.303.2017.01.05.20.38.53
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 20:38:54 -0800 (PST)
Date: Fri, 6 Jan 2017 13:38:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix some typos in mm/zsmalloc.c
Message-ID: <20170106043849.GA29688@bbox>
References: <58646FB7.2040502@huawei.com>
 <5864C12F.60709@huawei.com>
 <586F1823.4050107@huawei.com>
MIME-Version: 1.0
In-Reply-To: <586F1823.4050107@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 06, 2017 at 12:08:03PM +0800, Xishi Qiu wrote:
> Delete extra semicolon, and fix some typos.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
