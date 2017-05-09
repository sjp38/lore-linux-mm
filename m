Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0663831F4
	for <linux-mm@kvack.org>; Tue,  9 May 2017 07:06:03 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r31so40117404uar.13
        for <linux-mm@kvack.org>; Tue, 09 May 2017 04:06:03 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id d78si7846364vke.14.2017.05.09.04.06.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 04:06:02 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 0/1 v2] mm: Use BIT macro in SLAB bitmaps
Date: Tue, 9 May 2017 14:04:47 +0300
Message-ID: <20170509110448.7872-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Igor Stoppa <igor.stoppa@huawei.com>

The file include/linux/slab.h can be simplified by moving to use the
macro BIT() and making other bitmaps depend on their correspective
master-toggle configuration option.

checkpatch.pl will generate some warnings about line lenght, but I didn't
want to alter the initial layout, which already sufferend from this
problem.

The previous version was redefining a macro that is used by the exinos bsp.

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
