Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A25596B03C5
	for <linux-mm@kvack.org>; Mon,  8 May 2017 09:21:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b28so12527282wrb.2
        for <linux-mm@kvack.org>; Mon, 08 May 2017 06:21:35 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id o21si13674222wmi.72.2017.05.08.06.21.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 May 2017 06:21:34 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 0/1] mm: Use BIT macro in SLAB bitmaps
Date: Mon, 8 May 2017 16:20:21 +0300
Message-ID: <20170508132022.15488-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Igor Stoppa <igor.stoppa@huawei.com>

The file include/linux/slab.h can be simplified by moving to use the
macro BIT() and making other bitmaps depend on their correspactive
master-toggle configuration option.

Igor Stoppa (1):
  Rework slab bitmasks

 include/linux/slab.h | 71 +++++++++++++++++++++++-----------------------------
 1 file changed, 31 insertions(+), 40 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
