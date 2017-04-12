Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 404026B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 08:49:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c62so20432535oia.13
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 05:49:26 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00106.outbound.protection.outlook.com. [40.107.0.106])
        by mx.google.com with ESMTPS id f42si7991037oth.119.2017.04.12.05.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 05:49:24 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 0/5] allow to call vfree() in atomic context
Date: Wed, 12 Apr 2017 15:49:00 +0300
Message-ID: <20170412124905.25443-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170330102719.13119-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com

Changes since v1:
 - Added small optmization as a separate patch 5/5
 - Collected Acks/Review tags.


Andrey Ryabinin (5):
  mm/vmalloc: allow to call vfree() in atomic context
  x86/ldt: use vfree() instead of vfree_atomic()
  kernel/fork: use vfree() instead of vfree_atomic() to free thread
    stack
  mm/vmalloc: remove vfree_atomic()
  mm/vmalloc: Don't spawn workers if somebody already purging

 arch/x86/kernel/ldt.c   |  2 +-
 include/linux/vmalloc.h |  1 -
 kernel/fork.c           |  2 +-
 mm/vmalloc.c            | 52 +++++++++++--------------------------------------
 4 files changed, 13 insertions(+), 44 deletions(-)

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
