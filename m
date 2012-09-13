Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 257746B0181
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 17:27:45 -0400 (EDT)
Date: Fri, 14 Sep 2012 07:27:32 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-Id: <20120914072732.637f4225c32565468f468305@canb.auug.org.au>
In-Reply-To: <20120913120514.135d2c38.akpm@linux-foundation.org>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
	<1347382036-18455-4-git-send-email-will.deacon@arm.com>
	<20120913120514.135d2c38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__14_Sep_2012_07_27_32_+1000_pgH6OJmezGaynvnj"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

--Signature=_Fri__14_Sep_2012_07_27_32_+1000_pgH6OJmezGaynvnj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 13 Sep 2012 12:05:14 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> diff -puN arch/x86/Kconfig~mm-introduce-have_arch_transparent_hugepage ar=
ch/x86/Kconfig
> --- a/arch/x86/Kconfig~mm-introduce-have_arch_transparent_hugepage
> +++ a/arch/x86/Kconfig
> @@ -83,7 +83,6 @@ config X86
>  	select IRQ_FORCED_THREADING
>  	select USE_GENERIC_SMP_HELPERS if SMP
>  	select HAVE_BPF_JIT if X86_64
> -	select HAVE_ARCH_TRANSPARENT_HUGEPAGE

Why not
	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if MMU

>  	select CLKEVT_I8253
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	select GENERIC_IOMAP
> @@ -1330,6 +1329,10 @@ config ILLEGAL_POINTER_VALUE
>         default 0 if X86_32
>         default 0xdead000000000000 if X86_64
> =20
> +config HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +       def_bool y
> +       depends on MMU
> +

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__14_Sep_2012_07_27_32_+1000_pgH6OJmezGaynvnj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQUk/EAAoJEECxmPOUX5FEPhYQAKmhRet965FrG861C8FuoYks
GP51hrnL0c5SRIzL/QQt+efYxh0tjFkShopokmeJBbiC71ffwY+YTGDeL5SsH4h/
rSj3qmFgxfb0HUzJeOgp9BuIn3RsKEY4Auj2k9KYR3ryFcXz+ZOeTLCBuNARXKEf
BKufAnbL56fDoV0c3RDvinTT2Sf42hxmpRQLLF1nQeoxRtF9zYmKH29hEYMFgU7a
23tAtS+HQd5tfJPi+C1Xc1YNXlXCTSVG8057VC/XdOfggOY5bx2AU4CX3dDiL5zV
4FczjZStLfPac/GXVlGJ6/D4Et+GSi8VrsUkBsHtgJgmv7w9fjrx2+ZOn3mR6Fny
oefCKHQF7OVC7EzaGXC1lW2CsiHEJGjd2V7XS0b36W9SCWZlNzsM670VysyS8Uwa
ykeemA+L+02aCPu3lUopPPzOHymoDxrDXUo5vV3CX9v5LHDIsTY7zgo0Po8nQAf4
gH+EghqvXWKAp0cia5vDuA1mCDMnx49HljEfErhc5eXxxwzDXTNfUk+zKKJxns8K
c7SmqhR4eW/FRxMoretS7Usx5us/USeOtKM85bwd0UUJ/8ILX94aozA1lvgmKhO9
iQ06oEYJ7Pxlmme39Bmnat/qst6f3+BntlMxQaUV62gOog2qgDFsLNHJhDqFtbiW
Qc5NLVwF52sAdlsi1zS2
=U84r
-----END PGP SIGNATURE-----

--Signature=_Fri__14_Sep_2012_07_27_32_+1000_pgH6OJmezGaynvnj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
