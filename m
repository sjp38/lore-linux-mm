Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7BD6828E5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 21:33:05 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r4so29389299oib.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 18:33:05 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l12si4784324iod.67.2016.06.08.18.33.04
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 18:33:05 -0700 (PDT)
Date: Thu, 9 Jun 2016 10:34:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: add zpool support
Message-ID: <20160609013411.GA29779@bbox>
References: <d2a7edd5e1f37d9daf4536927d1439df6f9dbd0a.1465378622.git.geliangtang@gmail.com>
 <CALZtONBj0a06T5pxu0AxnyQX8VreuhGxmdg-oMv6w6SJom9wpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBj0a06T5pxu0AxnyQX8VreuhGxmdg-oMv6w6SJom9wpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Geliang Tang <geliangtang@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Jun 08, 2016 at 10:51:28AM -0400, Dan Streetman wrote:
> On Wed, Jun 8, 2016 at 5:39 AM, Geliang Tang <geliangtang@gmail.com> wrote:
> > This patch adds zpool support for zram, it will allow us to use both
> > the zpool api and directly zsmalloc api in zram.
> 
> besides the problems below, this was discussed a while ago and I
> believe Minchan is still against it, as nobody has so far shown what
> the benefit to zram would be; zram doesn't need the predictability, or
> evictability, of zbud or z3fold.

Right.

Geliang, I cannot ack without any *detail* that what's the problem of
zram/zsmalloc, why we can't fix it in zsmalloc itself.
The zbud and zsmalloc is otally different design to aim different goal
determinism vs efficiency so you can choose what you want between zswap
and zram rather than mixing the features.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
