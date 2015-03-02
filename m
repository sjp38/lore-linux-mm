Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 66E906B0074
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 09:56:03 -0500 (EST)
Received: by qcyl6 with SMTP id l6so24929873qcy.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 06:56:03 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id w5si11831103qal.42.2015.03.02.06.55.58
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 06:55:58 -0800 (PST)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [RFC PATCH 4/4] arm: add support for memtest
Date: Mon,  2 Mar 2015 14:55:45 +0000
Message-Id: <1425308145-20769-5-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org

Add support for memtest command line option.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 arch/arm/mm/init.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 1609b02..3d0e9ae 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -335,6 +335,9 @@ void __init bootmem_init(void)
=20
 =09find_limits(&min, &max_low, &max_high);
=20
+=09early_memtest((phys_addr_t)min << PAGE_SHIFT,
+=09=09      (phys_addr_t)max_low << PAGE_SHIFT);
+
 =09/*
 =09 * Sparsemem tries to allocate bootmem in memory_present(),
 =09 * so must be done after the fixed reservations
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
