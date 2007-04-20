Message-Id: <20070420155154.898600123@chello.nl>
Date: Fri, 20 Apr 2007 17:51:54 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/10] per device dirty throttling -v5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

The latest version of the per device dirty throttling.

against 2.6.21-rc6-mm1; the first patch is for easy application.
Andrew can of course just drop the patch it reverts.

Merged BDI_DIRTY and BDI_UNSTABLE into BDI_RECLAIMABLE, and multiplied
bdi_stat_delta() by the number of counters summed.

Thanks to Miklos for pointing these out.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
