Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5ABD6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:56:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so12511679pgv.16
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:56:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u39sor1671984pgn.316.2017.12.19.03.56.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 03:56:12 -0800 (PST)
Date: Tue, 19 Dec 2017 20:56:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219115608.GD435@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219110452.GC435@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219110452.GC435@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>


d'oh... actually Ccing Andrew.

	-ss

---

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
