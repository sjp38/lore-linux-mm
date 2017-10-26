Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDE96B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:35:43 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m16so5655836iod.11
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:35:43 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id w10si3941023iof.246.2017.10.26.10.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:35:41 -0700 (PDT)
Date: Fri, 27 Oct 2017 01:35:12 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH 0/4] add error handle for bdi debugfs register
Message-ID: <cover.1509038624.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org


this series add error handle for bdi debugfs register flow, the first
three patches try to convert void function to int and do some cleanup
if create dir or file fail.

the fourth patch only add a WARN_ON in device_add_disk, no function change.

weiping zhang (4):
  bdi: add check for bdi_debug_root
  bdi: convert bdi_debug_register to int
  bdi: add error handle for bdi_debug_register
  block: add WARN_ON if bdi register fail

 block/genhd.c    |  4 +++-
 mm/backing-dev.c | 41 +++++++++++++++++++++++++++++++++++------
 2 files changed, 38 insertions(+), 7 deletions(-)

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
