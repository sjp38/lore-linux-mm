Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA7146B00AC
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 23:10:22 -0500 (EST)
Date: Thu, 7 Jan 2010 13:06:31 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm] build fix for
 memcg-improve-performance-in-moving-swap-charge.patch
Message-Id: <20100107130631.144750c3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
	<20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

build fix in !CONFIG_CGROUP_MEM_RES_CTLR_SWAP case.

  CC      mm/memcontrol.o
mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
mm/memcontrol.c:3899: error: too many arguments to function 'mem_cgroup_move_swap_account'
mm/memcontrol.c:3899: error: too many arguments to function 'mem_cgroup_move_swap_account'
mm/memcontrol.c:3899: error: too many arguments to function 'mem_cgroup_move_swap_account'
make[1]: *** [mm/memcontrol.o] Error 1
make: *** [mm] Error 2

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
This can be applied after memcg-improve-performance-in-moving-swap-charge.patch.

 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5360d48..65df8d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2326,7 +2326,7 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
 {
 	return -EINVAL;
 }
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
