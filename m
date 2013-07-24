Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4D0AA6B0034
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:36:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 04:27:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 436F22BB004F
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:36:37 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6OILCtQ6816002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:21:12 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6OIaaSu029809
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:36:36 +1000
Message-ID: <51F01EB2.9060802@linux.vnet.ibm.com>
Date: Wed, 24 Jul 2013 13:36:34 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/8] Mark powerpc memory resources as busy
References: <51F01E06.6090800@linux.vnet.ibm.com>
In-Reply-To: <51F01E06.6090800@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

Memory I/O resources need to be marked as busy or else we cannot remove
them when doing memory hot remove.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 arch/powerpc/mm/mem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/arch/powerpc/mm/mem.c
===================================================================
--- linux.orig/arch/powerpc/mm/mem.c
+++ linux/arch/powerpc/mm/mem.c
@@ -523,7 +523,7 @@ static int add_system_ram_resources(void
 			res->name = "System RAM";
 			res->start = base;
 			res->end = base + size - 1;
-			res->flags = IORESOURCE_MEM;
+			res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 			WARN_ON(request_resource(&iomem_resource, res) < 0);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
