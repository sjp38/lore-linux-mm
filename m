Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE3E6B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:24:44 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bb5-v6so10010157plb.22
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 03:24:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b68sor3119pgc.405.2018.03.13.03.24.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 03:24:42 -0700 (PDT)
Date: Tue, 13 Mar 2018 19:24:37 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2 2/2] zram: drop max_zpage_size and use
 zs_huge_class_size()
Message-ID: <20180313102437.GA5114@jagdpanzerIV>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
 <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
 <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello Minchan,

On (03/13/18 18:02), Minchan Kim wrote:
> Sorry for being late.
> I love this patchset! Just a minor below.

:)

[..]
> > +	if (!huge_class_size)
> > +		huge_class_size = zs_huge_class_size();
> 
> If it is static, we can do this in zram_init? I believe it's more readable in that
> it's never changed betweens zram instances.

We need to have at least one pool, because pool decides where the
watermark is. At zram_init() stage we don't have a pool yet. We
zs_create_pool() in zram_meta_alloc() so that's why I put
zs_huge_class_size() there. I'm not in love with it, but that's
the only place where we can have it.

	-ss
