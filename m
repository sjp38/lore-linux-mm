Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7942682F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:07:51 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so25579171obc.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:07:51 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id o3si1965037obv.60.2015.10.29.12.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 12:07:50 -0700 (PDT)
Received: by obbwb3 with SMTP id wb3so25815224obb.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:07:50 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:07:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: mm Documentation: a little tidying in proc.txt
Message-ID: <alpine.LSU.2.11.1510291205481.3475@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

There's an odd line about "Locked" at the head of the description of
/proc/meminfo: it seems to have strayed from /proc/PID/smaps, so lead
it back there.  Move "Swap" and "SwapPss" descriptions down above it,
to match the order in the file (though "PageSize"s still undescribed).

The example of "Locked: 374 kB" (the same as Pss, neither Rss nor Size)
is so unlikely as to be misleading: just make it 0, this is /bin/bash
text; which would be "dw" (disabled write) not "de" (do not expand).

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 Documentation/filesystems/proc.txt |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

--- mmotm/Documentation/filesystems/proc.txt	2015-10-28 16:15:02.962646760 -0700
+++ linux/Documentation/filesystems/proc.txt	2015-10-28 17:09:24.035214415 -0700
@@ -433,8 +433,8 @@ Swap:                  0 kB
 SwapPss:               0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
-Locked:              374 kB
-VmFlags: rd ex mr mw me de
+Locked:                0 kB
+VmFlags: rd ex mr mw me dw
 
 the first of these lines shows the same information as is displayed for the
 mapping in /proc/PID/maps.  The remaining lines show the size of the mapping
@@ -454,13 +454,13 @@ accessed.
 "Anonymous" shows the amount of memory that does not belong to any file.  Even
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
-"Swap" shows how much would-be-anonymous memory is also used, but out on
-swap.
-"SwapPss" shows proportional swap share of this mapping.
 "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
 "Shared_Hugetlb" and "Private_Hugetlb" show the ammounts of memory backed by
 hugetlbfs page which is *not* counted in "RSS" or "PSS" field for historical
 reasons. And these are not included in {Shared,Private}_{Clean,Dirty} field.
+"Swap" shows how much would-be-anonymous memory is also used, but out on swap.
+"SwapPss" shows proportional swap share of this mapping.
+"Locked" indicates whether the mapping is locked in memory or not.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
@@ -824,9 +824,6 @@ varies by architecture and compile optio
 
 > cat /proc/meminfo
 
-The "Locked" indicates whether the mapping is locked in memory or not.
-
-
 MemTotal:     16344972 kB
 MemFree:      13634064 kB
 MemAvailable: 14836172 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
