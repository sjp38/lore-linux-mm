Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B92A6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:22:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 191so26745602pga.23
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:22:15 -0700 (PDT)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id q1si3292761pgn.400.2017.03.28.00.22.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 00:22:14 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC]mm/zsmalloc,: trigger BUG_ON in function zs_map_object.
Message-ID: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
Date: Tue, 28 Mar 2017 15:20:22 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hi, all,

We had backport the no-lru migration to linux-4.1, meanwhile change the
ZS_MAX_ZSPAGE_ORDER to 3. Then we met a BUG_ON(!page[1]).

It rarely happen, and presently, what I get is:
[6823.316528s]obj=a160701f, obj_idx=15, class{size:2176,objs_per_zspage:15,pages_per_zspage:8}
[...]
[6823.316619s]BUG: failure at /home/ethan/kernel/linux-4.1/mm/zsmalloc.c:1458/zs_map_object()! ----> BUG_ON(!page[1])

It seems that we have allocated an object from a ZS_FULL group?
(Actuallyi 1/4 ? I do not get the inuse number of this zspage, which I am trying to.)
And presently, I can not find why it happened. Any idea about it?

Any comment is more than welcome!

Thanks
Yisheng Xie



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
