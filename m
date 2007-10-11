Date: Thu, 11 Oct 2007 13:53:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [0/5]
Message-Id: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This set is a fix for memory cgroup against 2.6.23-rc8-mm2.
Not including any new feature.

If this is merged to the next -mm, I'm happy.

Patches:
[1/5] ... fix refcnt handling in charge mem_cgroup_charge()
[2/5] ... fix error handling path in mem_cgroup_charge()
[3/5] ... check page->cgroup under lock again.
[4/5] ... fix mem_cgroup_isolate_pages() to skip !PageLRU() pages.
[5/5] ... fix page migration under memory controller, fixes leak.

Changes from previous ones.
 -- dropped new feature.... force_empty patch. It will be posted later.
 -- fix typos
 -- added comments

Tested on x86-64/fake-NUMA system.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
