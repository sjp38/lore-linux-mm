From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 08 Aug 2006 21:34:25 +0200
Message-Id: <20060808193425.1396.92110.sendpatchset@lappy>
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Subject: [RFC][PATCH 6/9] tg3 driver conversion
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Update the driver to make use of the NETIF_F_MEMALLOC feature.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>

---
 drivers/net/tg3.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -11643,6 +11643,8 @@ static int __devinit tg3_init_one(struct
 	 */
 	pci_save_state(tp->pdev);
 
+	dev->features |= NETIF_F_MEMALLOC;
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register net device, "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
