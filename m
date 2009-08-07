Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5CD1A6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 23:23:40 -0400 (EDT)
Date: Fri, 7 Aug 2009 11:23:45 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: [PATCH] mmotm: slqb correctly return value for notification handler
Message-ID: <20090807032345.GA15686@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Correctly return value for notification handler. The bug causes other
handlers are ignored and panic kernel.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/slqb.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: mmotm/mm/slqb.c
===================================================================
--- mmotm.orig/mm/slqb.c	2009-08-07 11:14:39.000000000 +0800
+++ mmotm/mm/slqb.c	2009-08-07 11:17:36.000000000 +0800
@@ -2846,7 +2846,10 @@ static int slab_memory_callback(struct n
 		break;
 	}
 
-	ret = notifier_from_errno(ret);
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
