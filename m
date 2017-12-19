Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC606B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:04:58 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i33so7260773pld.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:04:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n2sor3151946pgr.214.2017.12.19.03.04.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 03:04:57 -0800 (PST)
Date: Tue, 19 Dec 2017 20:04:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219110452.GC435@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

Ccing Andrew
1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com

On (12/19/17 13:49), Aliaksei Karaliou wrote:
> 
> Structure zs_pool has special flag to indicate success of shrinker
> initialization. unregister_shrinker() has improved and can detect
> by itself whether actual deinitialization should be performed or not,
> so extra flag becomes redundant.
> 
> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>

looks good to me.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
