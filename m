Date: Wed, 31 Oct 2007 19:22:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory cgroup enhancements take 4 [0/8] intro
Message-Id: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, this set is for enhancements for memory cgroup I have now.
Tested on x86_64 and passed some tests.
All are against 2.6.23-mm1 + previous memory cgroup bugfix patches.

Any comments are welcome.

Patch contents:

[1/8] .... fix zone handling in try_to_free_mem_cgroup_page
		This is bug fix.

[2/8] .... force_empty interface for dropping all account in empty cgroup
		enhancements for easy deleting empty cgroup which was used
 		for memory control. Without this, deleting will fail
		in many case.

[3/8] .... remember "a page is charged as page cache"
		record as what a page is charged.

[4/8] .... remember "a page is on active list of cgroup or not"
		for future use. (can be skipped.)
		will be useful for reclaim routine enhance

[5/8] .... add status accounting function for memory cgroup
		infrastructure for accounting.
		will be used in memory.stat file

[6/8] .... add memory.stat file
		showing # of RSS and CACHEes by memory.stat file
		and other *memory specific* data in future.

[7/8] .... pre destroy handler
		add cgroup pre_destroy handler before calling destroy handler.

[8/8] .... implicit force_empty at rmdir()
		call force_empty in pre_destroy handler.
		This allows rmdir() to success always if cgroup is empty.

Reflected all comments against take3 and dropped zonestat.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
