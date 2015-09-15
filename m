Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E84D6B0257
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:09:57 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so166526266pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:09:57 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id pd2si29174637pbb.27.2015.09.14.23.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:09:56 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so166452278pad.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:09:56 -0700 (PDT)
Date: Tue, 15 Sep 2015 15:10:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH] mm: make zbud znd zpool to depend on zswap
Message-ID: <20150915061041.GB454@swordfish>
References: <1441888128-10897-1-git-send-email-sergey.senozhatsky@gmail.com>
 <CALZtONCSpXOB+8AZ4eVKfK8DeH0UX=ZuAK4zn8=UpVabP8pdNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCSpXOB+8AZ4eVKfK8DeH0UX=ZuAK4zn8=UpVabP8pdNg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (09/15/15 02:06), Dan Streetman wrote:
> > There are no zbud and zpool users besides zswap so enabling
> > (and building) CONFIG_ZPOOL and CONFIG_ZBUD make sense only
> > when CONFIG_ZSWAP is enabled. In other words, make those
> > options to depend on CONFIG_ZSWAP.
> 
> Let's wait on this until the patches to add zpool support to zram go
> one way or the other.  If they don't make it in, I'm fine with this,
> and even moving the zpool.h header into mm/ instead of include/linux/
> 

agree.

	-ss

> >
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/Kconfig | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 3455a8d..eb48422 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -563,6 +563,7 @@ config ZSWAP
> >
> >  config ZPOOL
> >         tristate "Common API for compressed memory storage"
> > +       depends on ZSWAP
> >         default n
> >         help
> >           Compressed memory storage API.  This allows using either zbud or
> > @@ -570,6 +571,7 @@ config ZPOOL
> >
> >  config ZBUD
> >         tristate "Low density storage for compressed pages"
> > +       depends on ZSWAP
> >         default n
> >         help
> >           A special purpose allocator for storing compressed pages.
> > --
> > 2.5.1
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
