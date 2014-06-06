Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id A44CC6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 23:57:54 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so2069959pbb.11
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 20:57:54 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gj4si16910391pbb.112.2014.06.05.20.57.51
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 20:57:53 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 0/2] Fix for memory online/offline.
Date: Fri, 6 Jun 2014 11:58:52 +0800
Message-ID: <1402027134-14423-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org, toshi.kani@hp.com, tj@kernel.org, hpa@zytor.com, mingo@elte.hu, laijs@cn.fujitsu.com
Cc: isimatu.yasuaki@jp.fujitsu.com, hutao@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

These two patches does some fixes in memory online/offline process.

Tang Chen (2):
  mem-hotplug: Avoid illegal state prefixed with legal state when
    changing state of memory_block.
  mem-hotplug: Introduce MMOP_OFFLINE to replace the hard coding -1.

 drivers/base/memory.c          | 24 ++++++++++++------------
 include/linux/memory_hotplug.h |  9 +++++----
 mm/memory_hotplug.c            |  9 ++++++---
 3 files changed, 23 insertions(+), 19 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
