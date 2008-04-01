Date: Tue, 1 Apr 2008 17:28:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 0/6] memcg: radix tree page_cgroup v3.
Message-Id: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

Hi, this is v3. This includes some fixes and some experimentals.

Still on -rc5-mm1. I'm now wondering how to merge and test this set...

Major Changes from previous one:
 - fixed typos.
 - merged prefetch in page_cgroup.
 - added some experimentals.

patch 1-3 are already posted patches. patch 4 is for removing redundant codes.
I think patch 1-4 are ready to be tested widely.
patch 5/6 are experimantal but shows good numbers.

This is performance result.
(CONFIG is changed to use sparsemem_vmemmap)

==
BYTE UNIX Benchmarks (Version 4.1.0) Run execl. x86_64/SMP/2CPUs.
Higher value is better. All are measured just after boot.

ENVIRON        : TEST               BASELINE     RESULT      INDEX

mem_cgorup=off : Execl Throughput       43.0     3150.1      732.6
before this set: Execl Throughput       43.0     2932.6      682.0
after patch 1-4: Execl Throughput       43.0     2899.1      674.2
after patch 1-6: Execl Throughput       43.0     3044.2      708.0
==

Because patch 5/6 is very aggressive but attractive,
I'd like to hear review/test comments.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
