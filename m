Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC13C6B026B
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:37:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y5so16524469pgq.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:37:40 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id 31si1250694plk.332.2017.10.31.03.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:37:39 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:37:32 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH v2 0/3] add error handle for bdi debugfs register
Message-ID: <cover.1509415695.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

Hello,

Change since V1:
 * remove the patch for bdi_debug_init(), because patch1 add a check
   for bdi_debug_root
 * remove bdi_put in bdi_register, this functions has two callers:
caller1: mtd_bdi_init->bdi_register, bdi_put if register fail
caller2: device_add_disk->bdi_register_owner->bdi_register, this call
stack need more safety cleanup, so patch3 add an WARN_ON.

weiping zhang (3):
  bdi: convert bdi_debug_register to int
  bdi: add error handle for bdi_debug_register
  block: add WARN_ON if bdi register fail

 block/genhd.c    |  2 +-
 mm/backing-dev.c | 22 +++++++++++++++++++---
 2 files changed, 20 insertions(+), 4 deletions(-)

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
