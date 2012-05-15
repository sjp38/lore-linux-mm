Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A4F1F6B00EA
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:37:21 -0400 (EDT)
Received: by wibhr14 with SMTP id hr14so2531619wib.8
        for <linux-mm@kvack.org>; Tue, 15 May 2012 07:37:19 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <4FB1BFFC.8080405@kernel.org>
References: <1336985134-31967-1-git-send-email-minchan@kernel.org>
	<1336985134-31967-2-git-send-email-minchan@kernel.org>
	<4FB119CA.2080606@linux.vnet.ibm.com>
	<4FB1BFFC.8080405@kernel.org>
Date: Tue, 15 May 2012 10:37:19 -0400
Message-ID: <CAPbh3rvOKvo5cxVR5f35xAmzJ_uoR+SO2dzoJzvLi4mMnm-DZQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] zram: remove comment in Kconfig
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>
> =3D=3D CUT_HERE =3D=3D
>
> >From be81aec5a4f35139aae2bf3d18139fbc114897ca Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 15 May 2012 11:26:48 +0900
> Subject: [PATCH] [zram,zcache] remove dependency with x86
>
> Exactly saying, [zram|zcache] should has a dependency with
> zsmalloc, not x86. So replace x86 dependeny with ZSMALLOC.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> ---
> =A0drivers/staging/zcache/Kconfig | =A0 =A03 +--
> =A0drivers/staging/zram/Kconfig =A0 | =A0 =A03 +--
> =A02 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kcon=
fig
> index 7048e01..ceb7f28 100644
> --- a/drivers/staging/zcache/Kconfig
> +++ b/drivers/staging/zcache/Kconfig
> @@ -2,8 +2,7 @@ config ZCACHE
> =A0 =A0 =A0 =A0bool "Dynamic compression of swap pages and clean pagecach=
e pages"
> =A0 =A0 =A0 =A0# X86 dependency is because zsmalloc uses non-portable pte=
/tlb
> =A0 =A0 =A0 =A0# functions
> - =A0 =A0 =A0 depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=3Dy && X86
> - =A0 =A0 =A0 select ZSMALLOC
> + =A0 =A0 =A0 depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=3Dy && ZSMAL=
LOC
> =A0 =A0 =A0 =A0select CRYPTO_LZO
> =A0 =A0 =A0 =A0default n
> =A0 =A0 =A0 =A0help
> diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
> index 9d11a4c..e3ac62d 100644
> --- a/drivers/staging/zram/Kconfig
> +++ b/drivers/staging/zram/Kconfig
> @@ -2,8 +2,7 @@ config ZRAM
> =A0 =A0 =A0 =A0tristate "Compressed RAM block device support"
> =A0 =A0 =A0 =A0# X86 dependency is because zsmalloc uses non-portable pte=
/tlb
> =A0 =A0 =A0 =A0# functions
> - =A0 =A0 =A0 depends on BLOCK && SYSFS && X86
> - =A0 =A0 =A0 select ZSMALLOC
> + =A0 =A0 =A0 depends on BLOCK && SYSFS && ZSMALLOC
> =A0 =A0 =A0 =A0select LZO_COMPRESS
> =A0 =A0 =A0 =A0select LZO_DECOMPRESS
> =A0 =A0 =A0 =A0default n
> --
> 1.7.9.5
>
>
>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
