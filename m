Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 361046B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 02:43:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j4so2671265pfc.8
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 23:43:19 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id w13si6452676pgm.221.2017.03.28.23.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 23:43:18 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 79so1473548pgf.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 23:43:18 -0700 (PDT)
Date: Wed, 29 Mar 2017 15:42:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC]mm/zsmalloc,: trigger BUG_ON in function zs_map_object.
Message-ID: <20170329064206.GA512@tigerII.localdomain>
References: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
 <20170329002029.GA18979@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329002029.GA18979@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On (03/29/17 09:20), Minchan Kim wrote:
> Hello,
> 
> On Tue, Mar 28, 2017 at 03:20:22PM +0800, Yisheng Xie wrote:
> > Hi, all,
> > 
> > We had backport the no-lru migration to linux-4.1, meanwhile change the
> > ZS_MAX_ZSPAGE_ORDER to 3. Then we met a BUG_ON(!page[1]).
> 
> Hmm, I don't know how you backported.
> 
> There isn't any problem with default ZS_MAX_ZSPAGE_ORDER. Right?
> So, it happens only if you changed it to 3?

I agree with Minchan. too much things could have gone wrong during the backport.

> Could you tell me what is your base kernel? and what zram/zsmalloc
> version(ie, from what kernel version) you backported to your
> base kernel?

agree again.



Yisheng, do you have this commit applied?

commit c102f07ca0b04f2cb49cfc161c83f6239d17f491
Author: Junil Lee <junil0814.lee@lge.com>
Date:   Wed Jan 20 14:58:18 2016 -0800

    zsmalloc: fix migrate_zspage-zs_free race condition


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
