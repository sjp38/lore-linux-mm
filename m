Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 645766B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 20:32:14 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/18] mm: Generate kmemtrace trace points only if they are enabled
Date: Tue, 23 Mar 2010 01:32:05 +0100
Message-Id: <1269304340-25372-4-git-send-email-jack@suse.cz>
In-Reply-To: <1269304340-25372-1-git-send-email-jack@suse.cz>
References: <1269304340-25372-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CC: linux-mm@kvack.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/trace/events/kmem.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 3adca0c..1f93693 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -1,5 +1,7 @@
 #undef TRACE_SYSTEM
+#undef TRACE_CONFIG
 #define TRACE_SYSTEM kmem
+#define TRACE_CONFIG CONFIG_KMEMTRACE
 
 #if !defined(_TRACE_KMEM_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_KMEM_H
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
