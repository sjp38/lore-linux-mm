Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAC26B02B4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:18:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a82so4947078pfc.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:18:49 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 16si289825pfq.152.2017.06.21.21.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 21:18:48 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y7so1072368pfd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:18:48 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] docs/memory-hotplug: adjust the explanation of valid_zones sysfs
Date: Thu, 22 Jun 2017 12:18:44 +0800
Message-Id: <20170622041844.9852-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

After commit "mm, memory_hotplug: do not associate hotadded memory to zones
until online", the meaning of valid_zones is changed.

1. When the memory block is online, it returns the onlined zone name
2. We won't have "Movable Normal" case, because default_zone couldn't be
MOVABLE

This patch adjust the document according the code change.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 Documentation/memory-hotplug.txt | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 670f3ded0802..d85ceb53f52a 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -171,15 +171,15 @@ Under each memory block, you can see 5 files:
                     block is removable and a value of 0 indicates that
                     it is not removable. A memory block is removable only if
                     every section in the block is removable.
-'valid_zones'     : read-only: designed to show which zones this memory block
-		    can be onlined to.
-		    The first column shows it's default zone.
+'valid_zones'     : read-only: shows different information based on state.
+		    When state is online, it is designed to show the
+		    zone name this memory block is onlined to.
+		    When state is offline, it is designed to show which zones
+		    this memory block can be onlined to.  The first column
+		    shows it's default zone.
 		    "memory6/valid_zones: Normal Movable" shows this memoryblock
 		    can be onlined to ZONE_NORMAL by default and to ZONE_MOVABLE
 		    by online_movable.
-		    "memory7/valid_zones: Movable Normal" shows this memoryblock
-		    can be onlined to ZONE_MOVABLE by default and to ZONE_NORMAL
-		    by online_kernel.
 
 NOTE:
   These directories/files appear after physical memory hotplug phase.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
