Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D10E66B01A3
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:29 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 18:17:28 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E5DE86E803C
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:22 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MHPjW287962
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MHPVc010430
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:25 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 0/4] misc patches related to resizing nodes & zones
Date: Wed,  1 May 2013 15:17:11 -0700
Message-Id: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

The first 3 are simply comment fixes and clarifications on locking.

The last 1 adds additional locking when updating node_present_pages based on
the existing documentation.

Cody P Schafer (4):
  mmzone: make holding lock_memory_hotplug() a requirement for updating
    pgdat size
  mm: fix comment referring to non-existent size_seqlock, change to
    span_seqlock
  mmzone: note that node_size_lock should be manipulated via
    pgdat_resize_lock()
  memory_hotplug: use pgdat_resize_lock() when updating
    node_present_pages

 include/linux/mmzone.h | 7 ++++++-
 mm/memory_hotplug.c    | 5 +++++
 2 files changed, 11 insertions(+), 1 deletion(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
