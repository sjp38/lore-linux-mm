Date: Fri, 14 Mar 2008 18:59:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/7] memcg: radix-tree page_cgroup
Message-Id: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a patch set for implemening page_cgroup under radix-tree.
against 2.6.25-rc5-mm1.

Before this patch, page and page_cgroup relationship is

    pfn <-> struct page <-> struct page_cgroup
    lock for page_cgroup is in struct page.

After this patch, 
    struct page <-> pfn <-> struct page_cgroup.
    lock for page_cgroup is in struct page_cgroup itself.

Pros.
   - we can remove an extra pointer in struct page.
   - lock for page_cgroup is moved to page_cgroup inself from struct page.
Cons.
   - For avoiding too much access to radix-tree, some kind of workaround is
     necessary. On this patch set, page_cgroup is managed by chunk of an order.

I think this will hunk with patches which are already merged into -mm tree.
So, if I got positive answers from people, I'd like to rebase this to the next
-mm again in the next week.

Changes from previous (preview) version.
 - page migration algorithm is changed. (thanks to Chrisotph)
 - freeing routine is added.

I did tested on ia64/NUMA box. My x86_64 box is busy....
I'm glad if someone test this in his own box.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
