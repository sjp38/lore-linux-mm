Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 804246B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:13:41 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so114005105pac.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:13:41 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id tr2si16118332pac.112.2015.11.27.04.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 04:13:40 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v3 0/3] zsmalloc: make its pages can be migrated
Date: Fri, 27 Nov 2015 20:12:28 +0800
Message-ID: <1448626351-27380-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

These patches updated according to the review for the prev version [1].
So they are based on "[RFCv3 0/5] enable migration of driver pages" [2]
and "[RFC zsmalloc 0/4] meta diet" [3].

Hui Zhu (3):
zsmalloc: make struct can move
zsmalloc: mark its page "PageMobile"
zram: make create "__GFP_MOVABLE" pool

[1] http://comments.gmane.org/gmane.linux.kernel.mm/140014
[2] https://lkml.org/lkml/2015/7/7/21
[3] https://lkml.org/lkml/2015/8/10/90

 drivers/block/zram/zram_drv.c |    4 
 mm/zsmalloc.c                 |  392 +++++++++++++++++++++++++++++++++---------
 2 files changed, 316 insertions(+), 80 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
