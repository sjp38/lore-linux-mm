Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5EE6B0275
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:53:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x70so97275067pfk.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:53:16 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20122.outbound.protection.outlook.com. [40.107.2.122])
        by mx.google.com with ESMTPS id nw5si17771895pab.314.2016.10.25.08.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 08:53:15 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH 2/7] powerpc/vdso: remove unused params in vdso_do_func_patch{32,64}
Date: Tue, 25 Oct 2016 18:51:01 +0300
Message-ID: <20161025155106.29946-3-dsafonov@virtuozzo.com>
In-Reply-To: <20161025155106.29946-1-dsafonov@virtuozzo.com>
References: <20161025155106.29946-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Impact: cleanup

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org 
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/powerpc/kernel/vdso.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 4ffb82a2d9e9..278b9aa25a1c 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -309,7 +309,6 @@ static unsigned long __init find_function32(struct lib32_elfinfo *lib,
 }
 
 static int __init vdso_do_func_patch32(struct lib32_elfinfo *v32,
-				       struct lib64_elfinfo *v64,
 				       const char *orig, const char *fix)
 {
 	Elf32_Sym *sym32_gen, *sym32_fix;
@@ -344,7 +343,6 @@ static unsigned long __init find_function32(struct lib32_elfinfo *lib,
 }
 
 static int __init vdso_do_func_patch32(struct lib32_elfinfo *v32,
-				       struct lib64_elfinfo *v64,
 				       const char *orig, const char *fix)
 {
 	return 0;
@@ -419,8 +417,7 @@ static unsigned long __init find_function64(struct lib64_elfinfo *lib,
 #endif
 }
 
-static int __init vdso_do_func_patch64(struct lib32_elfinfo *v32,
-				       struct lib64_elfinfo *v64,
+static int __init vdso_do_func_patch64(struct lib64_elfinfo *v64,
 				       const char *orig, const char *fix)
 {
 	Elf64_Sym *sym64_gen, *sym64_fix;
@@ -619,11 +616,9 @@ static __init int vdso_fixup_alt_funcs(struct lib32_elfinfo *v32,
 		 * It would be easy to do, but doesn't seem to be necessary,
 		 * patching the OPD symbol is enough.
 		 */
-		vdso_do_func_patch32(v32, v64, patch->gen_name,
-				     patch->fix_name);
+		vdso_do_func_patch32(v32, patch->gen_name, patch->fix_name);
 #ifdef CONFIG_PPC64
-		vdso_do_func_patch64(v32, v64, patch->gen_name,
-				     patch->fix_name);
+		vdso_do_func_patch64(v64, patch->gen_name, patch->fix_name);
 #endif /* CONFIG_PPC64 */
 	}
 
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
