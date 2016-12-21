Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2D16B03B5
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:47:56 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id 41so150626304qtn.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:47:56 -0800 (PST)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 19si15296125qty.98.2016.12.21.07.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 07:47:55 -0800 (PST)
Received: by mail-qt0-x242.google.com with SMTP id p16so4024669qta.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:47:55 -0800 (PST)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: [Resend Patch 0/2] mm/memory_hotplug: fix hot remove bug
Message-ID: <b7ae8d10-da58-45cb-f088-f8adff299911@gmail.com>
Date: Wed, 21 Dec 2016 10:47:49 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, dave.hansen@linux.intel.com, vbabka@suse.cz, mgorman@techsingularity.net, qiuxishi@huawei.com

Here are two patches for memory hotplug:

Yasuaki Ishimatsu (2):
   mm/sparse: use page_private() to get page->private value
   mm/memory_hotplug: set magic number to page->freelsit instead
     of page->lru.next

  arch/x86/mm/init_64.c | 2 +-
  mm/memory_hotplug.c   | 5 +++--
  mm/sparse.c           | 4 ++--
  3 files changed, 6 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
