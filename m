Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE6406B00C3
	for <linux-mm@kvack.org>; Sat, 11 Sep 2010 03:09:33 -0400 (EDT)
Message-ID: <4C8B2AFA.2000705@kernel.org>
Date: Sat, 11 Sep 2010 00:08:42 -0700
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: [PATCH] powerpc, memblock: fix will memblock reference
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>	 <1281071724-28740-9-git-send-email-benh@kernel.crashing.org>	 <4C5BCD41.3040501@monstr.eu> <1281135046.2168.40.camel@pasglop>	 <4C88BD8F.5080208@monstr.eu>  <20100909115445.GB16157@elte.hu> <1284106711.6515.46.camel@pasglop> <4C8B2A9A.1040303@kernel.org>
In-Reply-To: <4C8B2A9A.1040303@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


for wii?

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Index: linux-2.6/arch/powerpc/platforms/embedded6xx/wii.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/embedded6xx/wii.c
+++ linux-2.6/arch/powerpc/platforms/embedded6xx/wii.c
@@ -65,7 +65,7 @@ static int __init page_aligned(unsigned
 
 void __init wii_memory_fixups(void)
 {
-	struct memblock_region *p = memblock.memory.region;
+	struct memblock_region *p = memblock.memory.regions;
 
 	/*
 	 * This is part of a workaround to allow the use of two

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
