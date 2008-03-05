Date: Wed, 5 Mar 2008 20:51:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Preview] [PATCH] radix tree based page cgroup [0/6]
Message-Id: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "taka@valinux.co.jp" <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi, this is the latest version of radix-tree based page cgroup patch.

I post this now because recent major changes are included in 2.6.25-rc4.
(I admit I should do more tests on this set.)

Almost all are rewritten and adjusted to rc4's logic.
I feel this set is simpler than previous one.

Patch series is following.
[1/6] page cgroup definition
[2/6] patch against charge/uncharge 
[3/6] patch against move_list
[4/6] patch against migration
[5/6] radix tree based page_cgroup
[6/6] boost by per-cpu cache.

 * force_empty patch is dropped because it's unnecessary.
 * vmalloc patch is dropped. we always use kmalloc in this version.

TODO:
  - add freeing page_cgroup routine. it seems necessary sometimes.
    (I have one and will be added to this set in the next post.)
  - Logic check again.

Thanks,
-Kame


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
