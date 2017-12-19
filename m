Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B65C06B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:22:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so14358222pfi.15
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 02:22:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor5717764plr.67.2017.12.19.02.22.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 02:22:17 -0800 (PST)
Date: Tue, 19 Dec 2017 19:22:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219102213.GA435@jagdpanzerIV>
References: <1513675289-8906-1-git-send-email-akaraliou.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513675289-8906-1-git-send-email-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

Hi,

On (12/19/17 12:21), Aliaksei Karaliou wrote:
> unregister_shrinker() has improved and can detect by itself whether
> actual deinitialization should be performed or not, so extra flag
> becomes redundant.

yay... could have happened 2 years earlier
https://marc.info/?l=linux-mm&m=143658322724908&w=2

> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>

could you add <linux/shrinker.h> include and re-spin the patch?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
