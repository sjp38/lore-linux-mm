Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id EEB3B6B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 05:19:33 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so5761188lbg.4
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 02:19:33 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id zl2si27826592lbb.25.2014.10.07.02.19.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 02:19:32 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id ge10so5885201lab.38
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 02:19:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412610847-27671-3-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1412610847-27671-1-git-send-email-a.ryabinin@samsung.com> <1412610847-27671-3-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 7 Oct 2014 13:19:12 +0400
Message-ID: <CACT4Y+bcn3cc=RfmAwAVJBjtdeQ7z9nNuNvsUiD6RvKnc7E=ZA@mail.gmail.com>
Subject: Re: [PATCH v4 02/13] efi: libstub: disable KASAN for efistub
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

looks good to me

On Mon, Oct 6, 2014 at 7:53 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> KASan as many other options should be disabled for this stub
> to prevent build failures.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  drivers/firmware/efi/libstub/Makefile | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/firmware/efi/libstub/Makefile b/drivers/firmware/efi/libstub/Makefile
> index b14bc2b..c5533c7 100644
> --- a/drivers/firmware/efi/libstub/Makefile
> +++ b/drivers/firmware/efi/libstub/Makefile
> @@ -19,6 +19,7 @@ KBUILD_CFLAGS                 := $(cflags-y) \
>                                    $(call cc-option,-fno-stack-protector)
>
>  GCOV_PROFILE                   := n
> +KASAN_SANITIZE                 := n
>
>  lib-y                          := efi-stub-helper.o
>  lib-$(CONFIG_EFI_ARMSTUB)      += arm-stub.o fdt.o
> --
> 2.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
