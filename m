Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F30D6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 21:29:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f64so17500436pfd.6
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 18:29:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v202si6244964pgb.283.2017.12.20.18.29.47
        for <linux-mm@kvack.org>;
        Wed, 20 Dec 2017 18:29:47 -0800 (PST)
Date: Thu, 21 Dec 2017 11:29:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171221022945.GB27475@bbox>
References: <06247d4c-82a7-ccf1-ad42-4ef751081011@gmail.com>
 <1513765309-19500-1-git-send-email-akaraliou.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513765309-19500-1-git-send-email-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, Dec 20, 2017 at 01:21:49PM +0300, Aliaksei Karaliou wrote:
> Structure zs_pool has special flag to indicate success of shrinker
> initialization. unregister_shrinker() has improved and can detect
> by itself whether actual deinitialization should be performed or not,
> so extra flag becomes redundant.
> 
> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
