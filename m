Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CAAC76B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 20:10:17 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so59044293pdb.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:10:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ci7si30014168pad.234.2015.08.24.17.10.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 17:10:16 -0700 (PDT)
In-Reply-To: <1440454482-12250-2-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com> <1440454482-12250-2-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 01/10] mm: make cleancache.c explicitly non-modular
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Mon, 24 Aug 2015 20:10:03 -0400
Message-ID: <F91A372A-4443-41C6-880F-5F6B66990FFA@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On August 24, 2015 6:14:33 PM EDT, Paul Gortmaker <paul=2Egortmaker@windriv=
er=2Ecom> wrote:
>The Kconfig currently controlling compilation of this code is:
>
>config CLEANCACHE
>bool "Enable cleancache driver to cache clean pages if tmem is present"
>
>=2E=2E=2Emeaning that it currently is not being built as a module by anyo=
ne=2E

Why not make it a tristate?


>
>Lets remove the couple traces of modularity so that when reading the
>driver there is no doubt it is builtin-only=2E
>
>Since module_init translates to device_initcall in the non-modular
>case, the init ordering remains unchanged with this commit=2E
>
>Cc: Konrad Rzeszutek Wilk <konrad=2Ewilk@oracle=2Ecom>
>Cc: linux-mm@kvack=2Eorg
>Signed-off-by: Paul Gortmaker <paul=2Egortmaker@windriver=2Ecom>
>---
> mm/cleancache=2Ec | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/mm/cleancache=2Ec b/mm/cleancache=2Ec
>index 8fc50811119b=2E=2Eee0646d1c2fa 100644
>--- a/mm/cleancache=2Ec
>+++ b/mm/cleancache=2Ec
>@@ -11,7 +11,7 @@
>  * This work is licensed under the terms of the GNU GPL, version 2=2E
>  */
>=20
>-#include <linux/module=2Eh>
>+#include <linux/init=2Eh>
> #include <linux/fs=2Eh>
> #include <linux/exportfs=2Eh>
> #include <linux/mm=2Eh>
>@@ -316,4 +316,4 @@ static int __init init_cleancache(void)
> #endif
> 	return 0;
> }
>-module_init(init_cleancache)
>+device_initcall(init_cleancache)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
