Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8CEF6B0347
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:15:13 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n21so25637866qka.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:15:13 -0800 (PST)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id m42si13044762qtb.102.2016.12.20.11.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 11:15:13 -0800 (PST)
Received: by mail-qk0-x243.google.com with SMTP id n21so5645791qka.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:15:13 -0800 (PST)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: [Patch 0/2] mm/memory_hotplug: fix hot remove bug
Message-ID: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
Date: Tue, 20 Dec 2016 14:15:08 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here are two patches for memory hotplug:

Yasuaki Ishimatsu (2):
   mm/sparse: use page_private() to get page->private value
   mm/memory_hotplug: set magic number to page->freelsit instead
     of page->lru.next

  arch/x86/mm/init_64.c | 2 +-
  mm/memory_hotplug.c   | 4 ++--
  mm/sparse.c           | 4 ++--
  3 files changed, 5 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
