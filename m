Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 10A176B006E
	for <linux-mm@kvack.org>; Mon,  4 May 2015 19:14:57 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so95982059qkg.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 16:14:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si14412500qga.33.2015.05.04.16.14.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 16:14:56 -0700 (PDT)
Subject: [net-next PATCH 2/6] netcp: Replace
 put_page(virt_to_head_page(ptr)) w/ skb_free_frag
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:14:53 -0700
Message-ID: <20150504231453.1538.70827.stgit@ahduyck-vm-fedora22>
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
