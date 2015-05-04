Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 597296B0072
	for <linux-mm@kvack.org>; Mon,  4 May 2015 19:15:14 -0400 (EDT)
Received: by qcvz3 with SMTP id z3so30857684qcv.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 16:15:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 47si13743842qgt.45.2015.05.04.16.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 16:15:13 -0700 (PDT)
Subject: [net-next PATCH 5/6] hisilicon: Replace
 put_page(virt_to_head_page()) with skb_free_frag()
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:15:11 -0700
Message-ID: <20150504231511.1538.48064.stgit@ahduyck-vm-fedora22>
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
 drivers/net/ethernet/hisilicon/hip04_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 3b39fdddeb57..d49bee38cd31 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -798,7 +798,7 @@ static void hip04_free_ring(struct net_device *ndev, struct device *d)
 
 	for (i = 0; i < RX_DESC_NUM; i++)
 		if (priv->rx_buf[i])
-			put_page(virt_to_head_page(priv->rx_buf[i]));
+			skb_free_frag(priv->rx_buf[i]);
 
 	for (i = 0; i < TX_DESC_NUM; i++)
 		if (priv->tx_skb[i])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
