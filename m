Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE596B0073
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:12 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so15383162qgf.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hz3si4444qcb.10.2015.05.06.21.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:12:10 -0700 (PDT)
Subject: [PATCH 06/10] netcp: Replace put_page(virt_to_head_page(ptr)) w/
 skb_free_frag
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:12:08 -0700
Message-ID: <20150507041208.1873.92668.stgit@ahduyck-vm-fedora22>
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
 drivers/net/ethernet/ti/netcp_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 43efc3a0cda5..0a28c07361cf 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -537,7 +537,7 @@ int netcp_unregister_rxhook(struct netcp_intf *netcp_priv, int order,
 static void netcp_frag_free(bool is_frag, void *ptr)
 {
 	if (is_frag)
-		put_page(virt_to_head_page(ptr));
+		skb_free_frag(ptr);
 	else
 		kfree(ptr);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
