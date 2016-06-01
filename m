Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66E666B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 17:39:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b124so23861951pfb.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 14:39:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v4si27677449pac.21.2016.06.01.14.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 14:39:37 -0700 (PDT)
Date: Wed, 1 Jun 2016 14:39:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-Id: <20160601143936.a7ad8eec093514e3ee54cc62@linux-foundation.org>
In-Reply-To: <1464736881-24886-12-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
	<1464736881-24886-12-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed,  1 Jun 2016 08:21:20 +0900 Minchan Kim <minchan@kernel.org> wrote:

> This patch introduces run-time migration feature for zspage.
> 
> ...
>
> +static void kick_deferred_free(struct zs_pool *pool)
> +{
> +	schedule_work(&pool->free_work);
> +}

When CONFIG_ZSMALLOC=m, what keeps all the data structures in place
during a concurrent rmmod?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
