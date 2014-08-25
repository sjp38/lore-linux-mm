Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id F05D16B0081
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:25:52 -0400 (EDT)
Received: by mail-oi0-f50.google.com with SMTP id a141so9419945oig.23
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:25:52 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id uq6si45344161obc.33.2014.08.25.01.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Aug 2014 01:25:52 -0700 (PDT)
Received: by mail-ob0-f174.google.com with SMTP id vb8so10245932obc.5
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:25:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140825043755.GE32620@bbox>
References: <1408668134-21696-1-git-send-email-minchan@kernel.org>
 <1408668134-21696-4-git-send-email-minchan@kernel.org> <CAFdhcLQXHoCT2tee8f1hb-XOsh4G5SQUGfhXtobNYjDq6MS9Ug@mail.gmail.com>
 <20140824235607.GJ17372@bbox> <CAFdhcLRvwifCVyoW5F9gdOGwcNd0PM679HckJY6+UDYV82n+bg@mail.gmail.com>
 <20140825043755.GE32620@bbox>
From: Dongsheng Song <dongsheng.song@gmail.com>
Date: Mon, 25 Aug 2014 16:25:31 +0800
Message-ID: <CAE8XmWojKVaaY2GzRnpOVzc9cMeX2fb3nRC0JyBgrhPu1QaBEw@mail.gmail.com>
Subject: Re: [PATCH v4 3/4] zram: zram memory size limitation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Horner <ds2horner@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

> +What:          /sys/block/zram<id>/mem_limit
> +Date:          August 2014
> +Contact:       Minchan Kim <minchan@kernel.org>
> +Description:
> +               The mem_limit file is read/write and specifies the amount
 > +               of memory to be able to consume memory to store store
> +               compressed data. The limit could be changed in run time
> +               and "0" means disable the limit. No limit is the initial state.

extra word 'store' ?
The mem_limit file is read/write and specifies the amount of memory to
be able to consume memory to store store compressed data.

maybe this better ?
The mem_limit file is read/write and specifies the amount of memory to
store compressed data.

--
Dongsheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
