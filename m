Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2AAC86B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:24:45 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECOfUB000479
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:24:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8345C45DE7F
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:24:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EBF745DE79
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:24:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D2B1DB8049
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:24:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D10561DB804A
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:24:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/8] Mark sleep_on as deprecated
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214212351.BBB4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:24:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>



sleep_on() function is SMP and/or kernel preemption unsafe. we shouldn't
use it on new code.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/wait.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index a48e16b..bf76627 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -427,11 +427,11 @@ static inline void remove_wait_queue_locked(wait_queue_head_t *q,
  * They are racy.  DO NOT use them, use the wait_event* interfaces above.
  * We plan to remove these interfaces.
  */
-extern void sleep_on(wait_queue_head_t *q);
-extern long sleep_on_timeout(wait_queue_head_t *q,
+extern void __deprecated sleep_on(wait_queue_head_t *q);
+extern long __deprecated sleep_on_timeout(wait_queue_head_t *q,
 				      signed long timeout);
-extern void interruptible_sleep_on(wait_queue_head_t *q);
-extern long interruptible_sleep_on_timeout(wait_queue_head_t *q,
+extern void __deprecated interruptible_sleep_on(wait_queue_head_t *q);
+extern long __deprecated interruptible_sleep_on_timeout(wait_queue_head_t *q,
 					   signed long timeout);
 
 /*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
