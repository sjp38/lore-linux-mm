Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 325EA6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 01:36:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D5vURA022818
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 14:57:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2465345DE6E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:57:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A2E4D45DE70
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:57:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC886E0800E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:57:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D13651DB8043
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:57:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/4] OOM analysis helper patch series v3
Message-Id: <20090713144924.6257.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 14:57:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

ChangeLog
 Since v2
   - Dropped "[4/5] add isolate pages vmstat" temporary because it become
     slightly big. Then, I plan to submit it as another patchset.
   - Rewrote many patch description (Thanks! Christoph)
 Since v1
   - Dropped "[5/5] add NR_ANON_PAGES to OOM log" patch
   - Instead, introduce "[5/5] add shmem vmstat" patch
   - Fixed unit bug (Thanks Minchan)
   - Separated isolated vmstat to two field (Thanks Minchan and Wu)
   - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
   - Rewrote some patch description (Thanks Christoph)

This patch series are tested on 2.6.31-rc2 + mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch
==========================

Current OOM log doesn't provide sufficient memory usage information. it cause
make confusion to lkml MM guys. 

this patch series add some memory usage information to OOM log output.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
