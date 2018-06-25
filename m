Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46B9A6B0010
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 21:47:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so7350026plo.9
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 18:47:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 82-v6sor633804pfj.110.2018.06.24.18.47.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 18:47:13 -0700 (PDT)
Date: Mon, 25 Jun 2018 10:47:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: make several functions and a struct static
Message-ID: <20180625014709.GC557@jagdpanzerIV>
References: <20180624213322.13776-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180624213322.13776-1-colin.king@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On (06/24/18 22:33), Colin King wrote:
> The functions zs_page_isolate, zs_page_migrate, zs_page_putback,
> lock_zspage, trylock_zspage and structure zsmalloc_aops are local to
> source and do not need to be in global scope, so make them static.
> 
> Cleans up sparse warnings:
> symbol 'zs_page_isolate' was not declared. Should it be static?
> symbol 'zs_page_migrate' was not declared. Should it be static?
> symbol 'zs_page_putback' was not declared. Should it be static?
> symbol 'zsmalloc_aops' was not declared. Should it be static?
> symbol 'lock_zspage' was not declared. Should it be static?
> symbol 'trylock_zspage' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss
