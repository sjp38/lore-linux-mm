Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C341E6B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 17:06:11 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id e128so97187423pfe.3
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:11 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id fd9si9205842pad.134.2016.04.09.14.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 14:06:10 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id q6so11497116pav.0
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:10 -0700 (PDT)
From: Rui Salvaterra <rsalvaterra@gmail.com>
Subject: [PATCH v2 0/2] lib: lz4: fix for big endian and cleanup
Date: Sat,  9 Apr 2016 22:05:33 +0100
Message-Id: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, Rui Salvaterra <rsalvaterra@gmail.com>

v2:
	 - Addressed GregKH's review and comments.


Hi,

The first patch fixes zram with lz4 compression on ppc64 (and big endian
architectures with efficient unaligned access), the second is just a
cleanup.

Thanks,

Rui


Rui Salvaterra (2):
  lib: lz4: fixed zram with lz4 on big endian machines
  lib: lz4: cleanup unaligned access efficiency detection

 lib/lz4/lz4defs.h | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
