Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 697F36B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 21:33:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o871XJ7u018427
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Sep 2010 10:33:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A5C045DE7D
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:33:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 098A345DE7C
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:33:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E06B91DB803A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:33:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A16741DB803B
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:33:15 +0900 (JST)
Date: Tue, 7 Sep 2010 10:28:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/3] memory hotplug: updates and bugfix for is_removable v3
Message-Id: <20100907102813.d633b8ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Thank you for review and comments. totally updated.

Problem:

/sys/devices/system/memory/memoryX/removable file shows whether the section
can be offlined or not. Returns "1" if it seems removable.
 
Now, the file uses a similar logic to one offline_pages() uses.
Then, it's better to use unified logic.

The biggest change from previous one is this patch just unifies is_removable()
and offline code's logic. No functional change in offline() code.
(is_removable code is updated to be better.)


Brief patch description:
1. bugfix for is_removable() check. I think this should be back ported. (updated)
2. bugfix for callback at counting immobile pages. (no change)
3. the unified new logic for is_remobable. (updated)

Because I'm moving house, my response may be delayd.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
