Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD61E6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 05:07:46 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A29F83EE0BC
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 19:07:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 849C845DE4E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 19:07:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CA4B45DE4D
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 19:07:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 604F11DB8038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 19:07:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 117081DB802C
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 19:07:43 +0900 (JST)
Date: Fri, 2 Dec 2011 19:06:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-Id: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org

I'm now testing this patch, removing PCG_ACCT_LRU, onto mmotm.
How do you think ?

Here is a performance score at running page fault test.
==
[Before]
    11.20%   malloc  [kernel.kallsyms]  [k] clear_page_c
    ....
     1.80%   malloc  [kernel.kallsyms]  [k] __mem_cgroup_commit_charge
     0.94%   malloc  [kernel.kallsyms]  [k] mem_cgroup_lru_add_list
     0.87%   malloc  [kernel.kallsyms]  [k] mem_cgroup_lru_del_list

[After]
    11.66%   malloc  [kernel.kallsyms]  [k] clear_page_c
    2.17%   malloc  [kernel.kallsyms]  [k] __mem_cgroup_commit_charge
    0.56%   malloc  [kernel.kallsyms]  [k] mem_cgroup_lru_add_list
    0.25%   malloc  [kernel.kallsyms]  [k] mem_cgroup_lru_del_list

==

seems attractive to me.

==
