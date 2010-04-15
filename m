Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7739C6B021C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:17:20 -0400 (EDT)
Date: Fri, 16 Apr 2010 08:50:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: + memcg-fix-prepare-migration.patch added to -mm tree
Message-Id: <20100416085003.23e5b476.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <201004130430.o3D4U2wE012716@imap1.linux-foundation.org>
References: <201004130430.o3D4U2wE012716@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: nishimura@mxp.nes.nec.co.jp, aarcange@redhat.com, balbir@in.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, stable@kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(Resend with adding Cc: linux-mm@kvack.org)

Andrew, please fold this one into memcg-fix-prepare-migration.patch.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

It seems that the original patch was mangled a bit when it was adjusted to mainline.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7a4c07a..eb25d93 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2522,7 +2522,6 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
 		css_put(&mem->css);
 	}
-	*ptr = mem;
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
