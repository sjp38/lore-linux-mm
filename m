Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3AA990014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 06:53:14 -0400 (EDT)
Received: by fxg9 with SMTP id 9so6227406fxg.14
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 03:53:11 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH -mmotm 0/2] fault-injection: improve naming and export symbols
Date: Mon,  1 Aug 2011 12:52:35 +0200
Message-Id: <1312195957-12223-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

This patchset depends on
fault-injection-add-ability-to-export-fault_attr-in-arbitrary-directory.patch

The main purpose of this patchset is to add ability for modules to utilize
the fault injection. MMC needs this in order to implement fault injection.

Per Forlin (2):
  fault-injection: improve naming of public function should_fail()
  fault-injection: export fault injection functions

 Documentation/fault-injection/fault-injection.txt |    8 ++++----
 block/blk-core.c                                  |    3 ++-
 block/blk-timeout.c                               |    2 +-
 include/linux/fault-inject.h                      |    2 +-
 lib/fault-inject.c                                |    4 +++-
 mm/failslab.c                                     |    2 +-
 mm/page_alloc.c                                   |    2 +-
 7 files changed, 13 insertions(+), 10 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
