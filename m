Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E641A6B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 03:00:19 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so914890pad.8
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 00:00:19 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ym9si8498332pab.72.2014.07.14.00.00.17
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 00:00:18 -0700 (PDT)
Date: Mon, 14 Jul 2014 16:06:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: remove loop redundancy in mm/slub.c
Message-ID: <20140714070613.GF11317@js1304-P5Q-DELUXE>
References: <1405127350-13863-1-git-send-email-holuyaa@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405127350-13863-1-git-send-email-holuyaa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyoungho Choi <holuyaa@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Jul 12, 2014 at 10:09:10AM +0900, Hyoungho Choi wrote:
> set_freepointer() is invoked twice for first object at new_slab().
> Remove it.

Hello,

Same patch was already posted by Wei Yang. See the below.

https://lkml.org/lkml/2014/6/24/92

And, it is merged in a little bit different form for maintenance reason.

https://lkml.org/lkml/2014/7/3/404

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
