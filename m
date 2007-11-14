Date: Wed, 14 Nov 2007 17:39:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][ for -mm] memory controller enhancements for NUMA [0/10]
 introduction
Message-Id: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

This is a patch-set for memory controlelr on NUMA. 
patches are

1. record nid/zid on page_cgroup struct
2. record per-zone active/inactive
3-9 Patches for isolate global-lru reclaiming and memory controller reclaming
10. implements per-zone LRU on memory controller.

now this is just RFC.

Tested on 
  2.6.24-rc2-mm1 + x86_64/fake-NUMA( # of nodes = 3)

I did test with numactl under memory limitation.
 % numactl -i 0,1,2 dd if=.....

It seems per-zone-lru works well.

I'd like to do test on ia64/real-NUMA when I have a chance.

Any comments are welcome.

Thanks,
 -kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
