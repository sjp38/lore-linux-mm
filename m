Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FA0A6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 03:50:23 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6985JHo014722
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 17:05:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FBE345DE4C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5197345DE4F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 387AA1DB803F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E3023E08008
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/5] OOM analysis helper patch series v2
Message-Id: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 17:05:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>


ChangeLog
 Since v1
   - Droped "[5/5] add NR_ANON_PAGES to OOM log" patch
   - Instead, introduce "[5/5] add shmem vmstat" patch
   - Fixed unit bug (Thanks Minchan)
   - Separated isolated vmstat to two field (Thanks Minchan and Wu)
   - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
   - Rewrote some patch description (Thanks Christoph)


Current OOM log doesn't provide sufficient memory usage information. it cause
make confusion to lkml MM guys. 

this patch series add some memory usage information to OOM log.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
