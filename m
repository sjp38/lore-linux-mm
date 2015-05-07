Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 52B646B0080
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:34 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so20380026qkg.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q63si894651qgd.39.2015.05.06.21.12.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:12:33 -0700 (PDT)
Subject: [PATCH 09/10] hisilicon: Replace put_page(virt_to_head_page()) with
 skb_free_frag()
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:12:25 -0700
Message-ID: <20150507041225.1873.74253.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

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
