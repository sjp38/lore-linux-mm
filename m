Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE0E6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:05:39 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so1454432pbc.2
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:05:39 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0119.outbound.protection.outlook.com. [65.55.169.119])
        by mx.google.com with ESMTPS id jw2si639115pbc.329.2014.05.14.02.05.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 May 2014 02:05:38 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [PATCHv2 0/2] Add IO mapping space reused support
Date: Wed, 14 May 2014 16:18:50 +0800
Message-ID: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, arnd@arndb.de, robherring2@gmail.com
Cc: lauraa@codeaurora.org, akpm@linux-foundation.org, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj8301@gmail.com>

Changes in V2:
 - Uses the atomic_t instead.
 - Revises some comment message.


Richard Lee (2):
  mm/vmalloc: Add IO mapping space reused interface support.
  ARM: ioremap: Add IO mapping space reused support.

 arch/arm/mm/ioremap.c   |  6 ++++
 include/linux/vmalloc.h |  5 +++
 mm/vmalloc.c            | 82 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
