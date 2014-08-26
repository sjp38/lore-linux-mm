Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4561B6B0037
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 00:50:10 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so22265868pab.2
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 21:50:09 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rp7si2558050pab.93.2014.08.25.21.50.07
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 21:50:09 -0700 (PDT)
Date: Tue, 26 Aug 2014 13:51:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 3/4] zram: zram memory size limitation
Message-ID: <20140826045100.GD11319@bbox>
References: <1408668134-21696-1-git-send-email-minchan@kernel.org>
 <1408668134-21696-4-git-send-email-minchan@kernel.org>
 <CAFdhcLQXHoCT2tee8f1hb-XOsh4G5SQUGfhXtobNYjDq6MS9Ug@mail.gmail.com>
 <20140824235607.GJ17372@bbox>
 <CAFdhcLRvwifCVyoW5F9gdOGwcNd0PM679HckJY6+UDYV82n+bg@mail.gmail.com>
 <20140825043755.GE32620@bbox>
 <CAE8XmWojKVaaY2GzRnpOVzc9cMeX2fb3nRC0JyBgrhPu1QaBEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAE8XmWojKVaaY2GzRnpOVzc9cMeX2fb3nRC0JyBgrhPu1QaBEw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dongsheng Song <dongsheng.song@gmail.com>
Cc: David Horner <ds2horner@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

Hello,

On Mon, Aug 25, 2014 at 04:25:31PM +0800, Dongsheng Song wrote:
> > +What:          /sys/block/zram<id>/mem_limit
> > +Date:          August 2014
> > +Contact:       Minchan Kim <minchan@kernel.org>
> > +Description:
> > +               The mem_limit file is read/write and specifies the amount
>  > +               of memory to be able to consume memory to store store
> > +               compressed data. The limit could be changed in run time
> > +               and "0" means disable the limit. No limit is the initial state.
> 
> extra word 'store' ?
> The mem_limit file is read/write and specifies the amount of memory to
> be able to consume memory to store store compressed data.
> 
> maybe this better ?
> The mem_limit file is read/write and specifies the amount of memory to
> store compressed data.

Will fix.
Thanks!

> 
> --
> Dongsheng
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
