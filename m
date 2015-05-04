Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9322F6B0070
	for <linux-mm@kvack.org>; Mon,  4 May 2015 19:15:06 -0400 (EDT)
Received: by widdi4 with SMTP id di4so126473740wid.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 16:15:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g2si13744119wiy.66.2015.05.04.16.15.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 16:15:05 -0700 (PDT)
Subject: [net-next PATCH 3/6] mvneta: Replace
 put_page(virt_to_head_page(ptr)) w/ skb_free_frag
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:14:59 -0700
Message-ID: <20150504231459.1538.21842.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, netdev@vger.kernel.org
Cc: akpm@linux-foundation.org, davem@davemloft.net

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/marvell/mvneta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..ecce8261ce3b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1359,7 +1359,7 @@ static void *mvneta_frag_alloc(const struct mvneta_port *pp)
 static void mvneta_frag_free(const struct mvneta_port *pp, void *data)
 {
 	if (likely(pp->frag_size <= PAGE_SIZE))
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
