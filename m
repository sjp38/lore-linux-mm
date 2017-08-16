Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D36A46B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:51:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x189so50827716pgb.11
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:51:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v8si7202960plg.655.2017.08.15.21.51.01
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 21:51:01 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:51:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: zs_page_migrate: schedule free_work if
 zspage is ZS_EMPTY
Message-ID: <20170816045059.GD24294@blaptop>
References: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com>
 <20170816021339.GA23451@blaptop>
 <CANFwon3kDOUKcUBmihVzSwkQ34MOGkEnAkOdHET+uv8XBoAWfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANFwon3kDOUKcUBmihVzSwkQ34MOGkEnAkOdHET+uv8XBoAWfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Aug 16, 2017 at 10:49:14AM +0800, Hui Zhu wrote:
> Hi Minchan,
> 
> 2017-08-16 10:13 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hi Hui,
> >
> > On Mon, Aug 14, 2017 at 05:56:30PM +0800, Hui Zhu wrote:
> >> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
> >
> > This patch is not merged yet so the hash is invalid.
> > That means we may fold this patch to [1] in current mmotm.
> >
> > [1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
> >
> >> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
> >> can handle the ZS_EMPTY zspage.
> >>
> >> But I got some false in zs_page_isolate:
> >>       if (get_zspage_inuse(zspage) == 0) {
> >>               spin_unlock(&class->lock);
> >>               return false;
> >>       }
> >
> > I also realized we should make zs_page_isolate succeed on empty zspage
> > because we allow the empty zspage migration from now on.
> > Could you send a patch for that as well?
> 
> OK.  I will make a patch for that later.

Please send the patch so I want to fold it to [1] before Andrew is going
to send [1] to Linus.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
