Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47DF36B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 05:55:18 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e4-v6so18441593qtp.15
        for <linux-mm@kvack.org>; Tue, 22 May 2018 02:55:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y27-v6si1202307qtc.254.2018.05.22.02.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 02:55:17 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 0/2] kasan: fix memory notifier handling
Date: Tue, 22 May 2018 11:55:13 +0200
Message-Id: <20180522095515.2735-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>

If onlining of pages fails, we don't properly free up memory.
Also, the memory hotplug notifier is not registered early enough, still
failing on certain setups where memory is detected, added and onlined
early.

David Hildenbrand (2):
  kasan: free allocated shadow memory on MEM_CANCEL_OFFLINE
  kasan: fix memory hotplug during boot

 mm/kasan/kasan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
2.17.0
