Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 162E76B0008
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:08:01 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c20-v6so18735714qkm.13
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:08:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n184-v6si3931381qkb.113.2018.05.22.03.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 03:08:00 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 0/2] kasan: fix memory notifier handling
Date: Tue, 22 May 2018 12:07:54 +0200
Message-Id: <20180522100756.18478-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>

If onlining of pages fails (is canceled), we don't properly free up memory.
Also, the memory hotplug notifier is not registered early enough, still
failing on certain setups where memory is detected, added and onlined
early.

v1 -> v2:
- s/MEM_CANCEL_OFFLINE/MEM_CANCEL_ONLINE

David Hildenbrand (2):
  kasan: free allocated shadow memory on MEM_CANCEL_ONLINE
  kasan: fix memory hotplug during boot

 mm/kasan/kasan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
2.17.0
