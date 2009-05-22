Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E8FD6B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 02:25:50 -0400 (EDT)
Message-ID: <4A1645D4.5010001@cn.fujitsu.com>
Date: Fri, 22 May 2009 14:27:32 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: remove forward declaration from sched.h
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This forward declaration seems pointless.

compile tested.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 sched.h |    1 -
 1 file changed, 1 deletion(-)

--- a/include/linux/sched.h	2009-05-22 13:43:01.000000000 +0800
+++ b/include/linux/sched.h	2009-05-22 13:38:59.000000000 +0800
@@ -93,7 +93,6 @@ struct sched_param {
 
 #include <asm/processor.h>
 
-struct mem_cgroup;
 struct exec_domain;
 struct futex_pi_state;
 struct robust_list_head;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
