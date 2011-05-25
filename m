Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 49F926B0012
	for <linux-mm@kvack.org>; Tue, 24 May 2011 23:13:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E6A0A3EE0BD
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C636845DE66
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC47E45DE5F
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C3EDEF800B
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 63246EF8002
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:13:03 +0900 (JST)
Message-ID: <4DDC73B7.1050409@jp.fujitsu.com>
Date: Wed, 25 May 2011 12:12:55 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] swap-token: makes global variables to function local
References: <4DD480DD.2040307@jp.fujitsu.com>	<4DD481A7.3050108@jp.fujitsu.com> <20110520123004.e81c932e.akpm@linux-foundation.org> <4DDB1388.2080102@jp.fujitsu.com>
In-Reply-To: <4DDB1388.2080102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

global_faults and last_aging are only used in grab_swap_token().
Then, they can be moved into grab_swap_token().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/thrash.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/thrash.c b/mm/thrash.c
index 0d41ff0..0504e8a 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -30,14 +30,14 @@
 static DEFINE_SPINLOCK(swap_token_lock);
 struct mm_struct *swap_token_mm;
 struct mem_cgroup *swap_token_memcg;
-static unsigned int global_faults;
-static unsigned int last_aging;

 void grab_swap_token(struct mm_struct *mm)
 {
 	int current_interval;
 	unsigned int old_prio = mm->token_priority;
 	struct mem_cgroup *memcg;
+	static unsigned int global_faults;
+	static unsigned int last_aging;

 	global_faults++;

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
