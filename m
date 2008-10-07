Date: Tue, 7 Oct 2008 19:01:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: update patch set v7
Message-Id: <20081007190121.d96e58a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Andrew. please allow me to test under -mm if ok.

This series is against the newest -mmotm(stamp-2008-10-02-16-17)
and I think ready-to-go.

All comments are reflected.
(and CONFIG_CGROUP_MEM_RES_CTLR=n case is fixed.)

Including following patches.

[1/6] ... account swap cache under lock
[2/6] ... set page->mapping to be NULL before uncharge
[3/6] ... avoid to account not-on-LRU pages.
[4/6] ... optimize per cpu statistics on memcg.
[5/6] ... make page_cgroup->flags atomic.
[6/6] ... allocate page_cgroup at boot.

I did tests I can. But I think patch 6/6 needs wider testers.
It has some dependency to configs/archs.

(*) the newest mmotm needs some patches to be driven.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
