Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B37066B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 01:46:25 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so162681821pac.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:46:25 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id rp5si12815898pab.52.2015.07.09.22.46.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 22:46:25 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so164163647pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:46:24 -0700 (PDT)
Date: Fri, 10 Jul 2015 14:46:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710054654.GE692@swordfish>
References: <1436506319-12885-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436506319-12885-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@lge.com>

On (07/10/15 14:31), Minchan Kim wrote:
> There is no reason to prevent select ZS_ALMOST_FULL as migration
> source if we cannot find source from ZS_ALMOST_EMPTY.
> 
> With this patch, zs_can_compact will return more exact result.
> 
> * From v1
>   * remove unnecessary found variable - Sergey
> 
> Signed-off-by: Minchan Kim <minchan.kim@lge.com>
> 

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
