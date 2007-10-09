Date: Tue, 9 Oct 2007 18:46:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][for -mm] Fix and Enhancements for memory cgroup [0/6] intro
Message-Id: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Balbir-san
This is a patch set against memory cgroup I have now.
Reflected comments I got.

= 
[1] charge refcnt fix patch     - avoid charging against a page which is being 
                                  uncharged.
[2] fix-err-handling patch      - remove unnecesary unlock_page_cgroup()
[3] lock and page->cgroup patch - add helper function for charge/uncharge
[4] avoid handling no LRU patch - makes mem_cgroup_isolate_pages() avoid
                                  handling !Page_LRU pages.
[5] migration fix patch         - a fix for page migration.
[6] force reclaim patch         - add an interface for uncharging all pages in
                                  empty cgroup.
=

BTW, which way would you like to go ?

  1. You'll merge this set (and my future patch) to your set as
     Memory Cgroup Maintainer and pass to Andrew Morton, later.
     And we'll work against your tree.
  2. I post this set to the (next) -mm. And we'll work agaisnt -mm.

not as my usual patch, tested on x86-64 fake-NUMA.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
