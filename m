Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFF26B0258
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:49:04 -0400 (EDT)
Received: by lanb10 with SMTP id b10so86783648lan.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:49:04 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id v7si9773050lav.62.2015.09.14.06.49.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:49:03 -0700 (PDT)
Received: by lagj9 with SMTP id j9so88263237lag.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:49:02 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:49:01 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-Id: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

While using ZRAM on a small RAM footprint devices, together with KSM, I ran into several occasions when moving pages from compressed swap back into the "normal" part of RAM caused significant latencies in system operation. By using zbud I lose in compression ratio but gain in determinism, lower latencies and lower fragmentation, so in the coming patches I tried to generalize what I've done to enable zbud for zram so far.

-- 
Vitaly Wool <vitalywool@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
