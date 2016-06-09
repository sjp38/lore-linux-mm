Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67838828E5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 21:43:47 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id jt9so13558225obc.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 18:43:47 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id lw5si4492514pab.156.2016.06.08.18.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 18:43:46 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id ug1so1575281pab.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 18:43:46 -0700 (PDT)
Date: Thu, 9 Jun 2016 10:43:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: add zpool support
Message-ID: <20160609014345.GB655@swordfish>
References: <d2a7edd5e1f37d9daf4536927d1439df6f9dbd0a.1465378622.git.geliangtang@gmail.com>
 <CALZtONBj0a06T5pxu0AxnyQX8VreuhGxmdg-oMv6w6SJom9wpQ@mail.gmail.com>
 <20160609013411.GA29779@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160609013411.GA29779@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Geliang Tang <geliangtang@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vitaly Wool <vitalywool@gmail.com>

Hello,

On (06/09/16 10:34), Minchan Kim wrote:
> On Wed, Jun 08, 2016 at 10:51:28AM -0400, Dan Streetman wrote:
> > On Wed, Jun 8, 2016 at 5:39 AM, Geliang Tang <geliangtang@gmail.com> wrote:
> > > This patch adds zpool support for zram, it will allow us to use both
> > > the zpool api and directly zsmalloc api in zram.
> > 
> > besides the problems below, this was discussed a while ago and I
> > believe Minchan is still against it, as nobody has so far shown what
> > the benefit to zram would be; zram doesn't need the predictability, or
> > evictability, of zbud or z3fold.
> 
> Right.
> 
> Geliang, I cannot ack without any *detail* that what's the problem of
> zram/zsmalloc, why we can't fix it in zsmalloc itself.
> The zbud and zsmalloc is otally different design to aim different goal
> determinism vs efficiency so you can choose what you want between zswap
> and zram rather than mixing the features.

I'd also probably Cc Vitaly Wool on this

(http://marc.info/?l=linux-mm&m=146537877415982&w=2)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
