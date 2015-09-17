Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7418B6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:26:13 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so4448217qkd.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 03:26:13 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id 195si1955020qhw.70.2015.09.17.03.26.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 03:26:12 -0700 (PDT)
Received: by qgev79 with SMTP id v79so8669178qge.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 03:26:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917013007.GB421@swordfish>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
	<20150917013007.GB421@swordfish>
Date: Thu, 17 Sep 2015 12:26:12 +0200
Message-ID: <CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Sep 17, 2015 at 1:30 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:

>
> just a side note,
> I'm afraid this is not how it works. numbers go first, to justify
> the patch set.
>

These patches are extension/alignment patches, why would anyone need
to justify that?

But just to help you understand where I am coming from, here are some numbers:
                               zsmalloc   zbud
kswapd_low_wmark_hit_quickly   4513       5696
kswapd_high_wmark_hit_quickly  861        902
allocstall                     2236       1122
pgmigrate_success              78229      31244
compact_stall                  1172       634
compact_fail                   194        95
compact_success                464        210

These are results from an Android device having run 3 'monkey' tests
each 20 minutes, with user switch to guest and back in between.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
