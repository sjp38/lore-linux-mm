Received: from smtp3.akamai.com (vwall3.sanmateo.corp.akamai.com [172.23.1.73])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2CJBU6O009515
	for <linux-mm@kvack.org>; Sat, 12 Mar 2005 11:11:32 -0800 (PST)
From: pmeda@akamai.com
Date: Sat, 12 Mar 2005 11:20:07 -0800
Message-Id: <200503121920.LAA06723@allur.sanmateo.akamai.com>
Subject: [PATCH] use strncpy in get_task_comm
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Set_task_comm uses strlcpy, so get_task_comm must use strncpy.

Signed-Off-by: Prasanna Meda <pmeda@akamai.com>

--- Linux/fs/exec.c	Sat Mar 12 01:12:47 2005
+++ linux/fs/exec.c	Sat Mar 12 17:27:49 2005
@@ -814,7 +814,7 @@
 {
 	/* buf must be at least sizeof(tsk->comm) in size */
 	task_lock(tsk);
-	memcpy(buf, tsk->comm, sizeof(tsk->comm));
+	strncpy(buf, tsk->comm, sizeof(tsk->comm));
 	task_unlock(tsk);
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
