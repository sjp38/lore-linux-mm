Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F22F6B02FA
	for <linux-mm@kvack.org>; Tue, 23 May 2017 00:05:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so150582366pfd.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:50 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u5si4323762pgj.197.2017.05.22.21.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 21:05:49 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id u26so24494595pfd.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:49 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 6/6] powerpc/mm: Enable ZONE_DEVICE on powerpc
Date: Tue, 23 May 2017 14:05:24 +1000
Message-Id: <20170523040524.13717-6-oohall@gmail.com>
In-Reply-To: <20170523040524.13717-1-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, Oliver O'Halloran <oohall@gmail.com>

Flip the switch. Running around and screaming "IT'S ALIVE" is optional,
but recommended.

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
 arch/powerpc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index f7c8f9972f61..bf3365c34244 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -138,6 +138,7 @@ config PPC
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_TICK_BROADCAST		if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_ZONE_DEVICE		if PPC64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
