Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE5A6B0256
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:11:07 -0500 (EST)
Received: by qkda6 with SMTP id a6so29107505qkd.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:11:07 -0800 (PST)
Received: from BLU004-OMC1S25.hotmail.com (blu004-omc1s25.hotmail.com. [65.55.116.36])
        by mx.google.com with ESMTPS id t130si7931852qhb.55.2015.11.19.11.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 11:11:06 -0800 (PST)
Message-ID: <BLU436-SMTP20633C03AB00B1A9777C8C8B91B0@phx.gbl>
Date: Fri, 20 Nov 2015 03:13:39 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: include linux/pfn.h for PHYS_PFN definition
References: <5841074.QcbTqgbsZz@wuerfel>
In-Reply-To: <5841074.QcbTqgbsZz@wuerfel>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, Chen Gang <gang.chen.5i5j@gmail.com>, Oleg Nesterov <oleg@redhat.com>


On 11/19/15 20:41=2C Arnd Bergmann wrote:
> A change to asm-generic/memory_model.h caused a new build error
> in some configurations:
>=20
> mach-clps711x/common.c:39:10: error: implicit declaration of function 'PH=
YS_PFN'
>    .pfn  =3D __phys_to_pfn(CLPS711X_PHYS_BASE)=2C
>=20
> This includes the linux/pfn.h header from the same file to avoid the
> error.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: bf1c6c9895de ("mm: add PHYS_PFN=2C use it in __phys_to_pfn()")
> ---
> I was listed as 'Cc' on the original patch=2C but don't see it in my inbo=
x.
>=20
> I can queue up the fixed version in the asm-generic tree if you like that=
=2C
> otherwise please fold this fixup into the patch=2C or drop it if we want =
to
> avoid the extra #include.
>=20
> diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/mem=
ory_model.h
> index c785a79d9385..5148150cc80b 100644
> --- a/include/asm-generic/memory_model.h
> +++ b/include/asm-generic/memory_model.h
> @@ -1=2C6 +1=2C8 @@
>  #ifndef __ASM_MEMORY_MODEL_H
>  #define __ASM_MEMORY_MODEL_H
> =20
> +#include <linux/pfn.h>
> +

For me=2C it is OK=2C thanks.

>  #ifndef __ASSEMBLY__
> =20
>  #if defined(CONFIG_FLATMEM)
>=20

--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
