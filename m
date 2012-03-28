Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 60F966B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 06:46:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8ADD33EE0BC
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:46:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7072445DE50
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:46:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 56B2745DE54
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:46:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33CDB1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:46:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC5691DB803E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:46:28 +0900 (JST)
Message-ID: <4F72EB84.7080000@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 19:44:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/6 v2] reducing page_cgroup size
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

Hi, here is v2 (still RFC again because I changed many parts.)
I'd like to post v3 without 'RFC' tag after Lsf-MM Summit.

This series is for reducing size of 'struct page_cgroup' to 8 bytes.
v2 contains 6 patches and did clean-ups and fixes race in v1 and
adds a trial to integrate struct page_cgroup into struct page.

each patches are...

1/6 ....add methods to access pc->mem_cgroup
2/6 ....add pc_set_mem_cgroup_and_flags() to set ->mem_cgroup and flags by one call.
3/6 ....add PageCgroupReset() for handling a race.
4/6 ....reduce size of struct page_cgroup by removing ->mem_cgroup
5/6 ....remove unnecessary memory barrier
6/6 ....add CONFIG_INTEGRATED_PAGE_CGROUP to place page_cgroup in struct page.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
