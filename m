Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4C39F6B01F0
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:33 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so60709918qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 123si4846409qhx.2.2015.05.21.13.24.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:32 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 31/36] IB/odp: export rbt_ib_umem_for_each_in_range()
Date: Thu, 21 May 2015 16:23:07 -0400
Message-Id: <1432239792-5002-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-rdma@vger.kernel.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The mlx5 driver will need this function for its driver specific bit
of ODP (on demand paging) on HMM (Heterogeneous Memory Management).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
cc: <linux-rdma@vger.kernel.org>
---
 drivers/infiniband/core/umem_rbtree.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/core/umem_rbtree.c b/drivers/infiniband/core/umem_rbtree.c
index 727d788..f030ec0 100644
--- a/drivers/infiniband/core/umem_rbtree.c
+++ b/drivers/infiniband/core/umem_rbtree.c
@@ -92,3 +92,4 @@ int rbt_ib_umem_for_each_in_range(struct rb_root *root,
 
 	return ret_val;
 }
+EXPORT_SYMBOL(rbt_ib_umem_for_each_in_range);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
