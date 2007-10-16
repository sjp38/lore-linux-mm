Date: Tue, 16 Oct 2007 19:19:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory cgroup enhancements [0/5] intro
Message-Id: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch set adds
 - force_empty interface, which drops all charges in memory cgroup.
   This enables rmdir() against unused memory cgroup.
 - the memory cgroup statistics accounting.

Based on 2.6.23-mm1 + http://lkml.org/lkml/2007/10/12/53

Changes from previous version is
 - merged comments.
 - based on 2.6.23-mm1
 - removed Charge/Uncharge counter.

[1/5] ... force_empty patch
[2/5] ... remember page is charged as page-cache patch
[3/5] ... remember page is on which list patch
[4/5] ... memory cgroup statistics patch
[5/5] ... show statistics patch

tested on x86-64/fake-NUMA + CONFIG_PREEMPT=y/n (for testing preempt_disable())

Any comments are welcome.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
