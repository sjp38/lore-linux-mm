Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D04776B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 09:45:36 -0400 (EDT)
Date: Fri, 1 May 2009 14:45:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2.6.30] Doc: hashdist defaults on for 64bit
In-Reply-To: <Pine.LNX.4.64.0905011354560.19012@blonde.anvils>
Message-ID: <Pine.LNX.4.64.0905011442540.19247@blonde.anvils>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
 <20090429142825.6dcf233d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0905011354560.19012@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, andi@firstfloor.org, davem@davemloft.net, anton@samba.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Update Doc: kernel boot parameter hashdist now defaults on for all 64bit NUMA.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 Documentation/kernel-parameters.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 2.6.30-rc4/Documentation/kernel-parameters.txt	2009-04-30 06:39:30.000000000 +0100
+++ linux/Documentation/kernel-parameters.txt	2009-05-01 14:08:56.000000000 +0100
@@ -775,7 +775,7 @@ and is between 256 and 4096 characters.
 
 	hashdist=	[KNL,NUMA] Large hashes allocated during boot
 			are distributed across NUMA nodes.  Defaults on
-			for IA-64, off otherwise.
+			for 64bit NUMA, off otherwise.
 			Format: 0 | 1 (for off | on)
 
 	hcl=		[IA-64] SGI's Hardware Graph compatibility layer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
