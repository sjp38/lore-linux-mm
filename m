Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BCD076B0012
	for <linux-mm@kvack.org>; Tue, 24 May 2011 23:02:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1E75E3EE0BD
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:02:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0528E45DE58
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:02:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E00E345DE54
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:02:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0EA3E08005
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:02:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93B03E08002
	for <linux-mm@kvack.org>; Wed, 25 May 2011 12:02:18 +0900 (JST)
Message-ID: <4DDC712C.8090509@jp.fujitsu.com>
Date: Wed, 25 May 2011 12:02:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] swap-token: fix dead link
References: <4DD480DD.2040307@jp.fujitsu.com>	<4DD481A7.3050108@jp.fujitsu.com> <20110520123004.e81c932e.akpm@linux-foundation.org> <4DDB1388.2080102@jp.fujitsu.com>
In-Reply-To: <4DDB1388.2080102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

http://www.cs.wm.edu/~sjiang/token.pdf is now dead. Then, this patch
replace it with an alive alternative.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/thrash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/thrash.c b/mm/thrash.c
index af46d67..0d41ff0 100644
--- a/mm/thrash.c
+++ b/mm/thrash.c
@@ -6,7 +6,7 @@
  * Released under the GPL, see the file COPYING for details.
  *
  * Simple token based thrashing protection, using the algorithm
- * described in:  http://www.cs.wm.edu/~sjiang/token.pdf
+ * described in: http://www.cse.ohio-state.edu/hpcs/WWW/HTML/publications/abs05-1.html
  *
  * Sep 2006, Ashwin Chaugule <ashwin.chaugule@celunite.com>
  * Improved algorithm to pass token:
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
