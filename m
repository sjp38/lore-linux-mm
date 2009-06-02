Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 981DB6B009A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:06:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5235wr5005067
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Jun 2009 12:05:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B79745DE51
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:05:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1151D45DD79
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:05:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EEE6B1DB803E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:05:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A99FC1DB803A
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:05:57 +0900 (JST)
Date: Tue, 2 Jun 2009 12:04:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] memcg fix swap accounting (2/Jun)
Message-Id: <20090602120425.0bcff554.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is an updated sereis of memcg fix swap accounting
 http://marc.info/?l=linux-mm&m=124348659700540&w=2

Now in mmotm as
 mm-add-swap-cache-interface-for-swap-reference.patch
 mm-modify-swap_map-and-add-swap_has_cache-flag.patch
 mm-reuse-unused-swap-entry-if-necessary.patch
 memcg-fix-swap-accounting.patch

No logic changes but fixed some condig style troubles pointed out.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
