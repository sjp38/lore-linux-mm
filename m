Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id ECA8E900015
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 06:27:37 -0400 (EDT)
Received: by wibbs8 with SMTP id bs8so18957991wib.4
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 03:27:37 -0700 (PDT)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id ln3si1635360wic.72.2015.03.09.03.27.32
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 03:27:33 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 3/6] arm64: add support for memtest
Date: Mon,  9 Mar 2015 10:27:07 +0000
Message-Id: <1425896830-19705-4-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org, baruch@tkos.co.il, rdunlap@infradead.org

Add support for memtest command line option.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
---
 arch/arm64/mm/init.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index ae85da6..597831b 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -190,6 +190,8 @@ void __init bootmem_init(void)
 =09min =3D PFN_UP(memblock_start_of_DRAM());
 =09max =3D PFN_DOWN(memblock_end_of_DRAM());
=20
+=09early_memtest(min << PAGE_SHIFT, max << PAGE_SHIFT);
+
 =09/*
 =09 * Sparsemem tries to allocate bootmem in memory_present(), so must be
 =09 * done after the fixed reservations.
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
