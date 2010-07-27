Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A2645600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:56:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R7uexa003961
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 16:56:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFBF245DE54
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:56:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B028945DE51
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:56:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 84EE21DB804F
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:56:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23F7E1DB8053
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 16:56:39 +0900 (JST)
Date: Tue, 27 Jul 2010 16:51:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/7][memcg] towards I/O aware memory cgroup
Message-Id: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


>From a view of patch management, this set is a mixture of a few features for
memcg, and I should divide them to some groups. But, at first, I'd like to
show the total view. This set is consists from 5 sets. Main purpose is
create a room in page_cgroup for I/O tracking and add light-weight access method
for file-cache related accounting. 

1.   An virtual-indexed array.
2,3. Use virtual-indexed array for id-to-memory_cgroup detection.
4.   modify page_cgroup to use ID instead of pointer, this gives us enough
     spaces for further memory tracking.
5,6   Use light-weight locking mechanism for file related accounting.
7.   use spin_lock instead of bit_spinlock.


As a function,  patch 5,6 can be an independent patch and I'll accept
reordering series of patch if someone requests.
But we'll need all, I think.
(irq_save for patch 7 will be required later.)

Any comments are welcome.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
