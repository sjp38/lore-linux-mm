Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99B7E6B0287
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:13:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cg13so202753343pac.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:13:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o4si7900128paa.223.2016.09.23.06.13.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 06:13:51 -0700 (PDT)
From: Robert Ho <robert.hu@intel.com>
Subject: [PATCH v3 2/2] Documentation/filesystems/proc.txt: Add more description for maps/smaps
Date: Fri, 23 Sep 2016 21:12:34 +0800
Message-Id: <1474636354-25573-2-git-send-email-robert.hu@intel.com>
In-Reply-To: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
References: <1474636354-25573-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, oleg@redhat.com, dan.j.williams@intel.com, dave.hansen@intel.com
Cc: guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, robert.hu@intel.com

Add some more description on the limitations for smaps/maps readings, as well
as some guaruntees we can make.

Signed-off-by: Robert Ho <robert.hu@intel.com>
---
 Documentation/filesystems/proc.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 68080ad..90eabc7 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -515,6 +515,14 @@ be vanished or the reverse -- new added.
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
 
+Note: for both /proc/PID/maps and /proc/PID/smaps readings, it's
+possible in race conditions, that the mappings printed may not be that
+up-to-date, because during each read walking, the task's mappings may have
+changed, this typically happens in multithread cases. But anyway in each single
+read these can be guarunteed: 1) the mapped addresses doesn't go backward; 2) no
+overlaps 3) if there is something at a given vaddr during the entirety of the
+life of the smaps/maps walk, there will be some output for it.
+
 The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
 bits on both physical and virtual pages associated with a process, and the
 soft-dirty bit on pte (see Documentation/vm/soft-dirty.txt for details).
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
