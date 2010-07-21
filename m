Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BD4526B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:45:00 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o6L2iv4d008589
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:57 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe18.cbf.corp.google.com with ESMTP id o6L2itUI015159
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:56 -0700
Received: by pwj6 with SMTP id 6so2639737pwj.16
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:55 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:44:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/6] sparc: remove dependency on __GFP_NOFAIL
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007201938100.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kmalloc() in mdesc_kmalloc() is failable, so remove __GFP_NOFAIL from
its mask.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/sparc/kernel/mdesc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -134,7 +134,7 @@ static struct mdesc_handle *mdesc_kmalloc(unsigned int mdesc_size)
 		       sizeof(struct mdesc_hdr) +
 		       mdesc_size);
 
-	base = kmalloc(handle_size + 15, GFP_KERNEL | __GFP_NOFAIL);
+	base = kmalloc(handle_size + 15, GFP_KERNEL);
 	if (base) {
 		struct mdesc_handle *hp;
 		unsigned long addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
