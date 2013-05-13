Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 59BFD6B0099
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:29 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 19:13:27 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C153138C8045
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:23 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DNDNvd260778
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DNDN2f000373
	for <linux-mm@kvack.org>; Mon, 13 May 2013 19:13:23 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 0/4] misc patches related to resizing nodes & zones
Date: Mon, 13 May 2013 16:13:03 -0700
Message-Id: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

First 2 are comment fixes.
Second 2 add pgdat_resize_lock()/unlock() usage per existing documentation.

--

Since v2 (http://comments.gmane.org/gmane.linux.kernel.mm/99316):
 - add ack on patch 1 from rientjes.
 - quote documentation in patch 3 & 4.

--

Since v1 (http://thread.gmane.org/gmane.linux.kernel.mm/99297):
  - drop making lock_memory_hotplug() required (old patch #1)
  - fix __offline_pages() in the same manner as online_pages() (rientjes)
  - make comment regarding pgdat_resize_lock()/unlock() usage more clear (rientjes)


Cody P Schafer (4):
  mm: fix comment referring to non-existent size_seqlock, change to
    span_seqlock
  mmzone: note that node_size_lock should be manipulated via
    pgdat_resize_lock()
  memory_hotplug: use pgdat_resize_lock() in online_pages()
  memory_hotplug: use pgdat_resize_lock() in __offline_pages()

 include/linux/mmzone.h | 5 ++++-
 mm/memory_hotplug.c    | 9 +++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
