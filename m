Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 80BA36B0044
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 18:42:58 -0400 (EDT)
Date: Wed, 25 Jul 2012 08:42:42 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 01/24] uprobes, mm, x86: Add the ability to install and
 remove uprobes breakpoints
Message-Id: <20120725084242.887ffaaf5a343ba8893b02c1@canb.auug.org.au>
In-Reply-To: <7c692867a3b75d6c2954b09339dd1b851998c997.1343163918.git.Torsten.Polle@gmx.de>
References: <cover.1343163918.git.Torsten.Polle@gmx.de>
	<7c692867a3b75d6c2954b09339dd1b851998c997.1343163918.git.Torsten.Polle@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__25_Jul_2012_08_42_42_+1000_oOvzmPTfYfh7ObKk"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Torsten Polle <Torsten.Polle@gmx.de>
Cc: tpolle@de.adit-jv.com, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>

--Signature=_Wed__25_Jul_2012_08_42_42_+1000_oOvzmPTfYfh7ObKk
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Torsten,

Just a couple of quick suggestions:

On Tue, 24 Jul 2012 23:12:45 +0200 Torsten Polle <Torsten.Polle@gmx.de> wro=
te:
>

Firstly, don't attach patches, put them inline in you email - it makes
it easier for reviewers to comment on them.

> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index c9866b0..1f5c307 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -243,6 +243,9 @@ config ARCH_CPU_PROBE_RELEASE
>  	def_bool y
>  	depends on HOTPLUG_CPU
> =20
> +config ARCH_SUPPORTS_UPROBES
> +	def_bool y
> +

You should put this in arch/Kconfig (as just a bool- no default) and
then select it in the x86 Kconfig.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__25_Jul_2012_08_42_42_+1000_oOvzmPTfYfh7ObKk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQDyTiAAoJEECxmPOUX5FEigIP/0WwfM4m6l0qU3le+e1F1Vxv
k0UBKLvMwotL62PCXVQ9ihvbvXpsS9LkcmfzO4/1WsZRAKpE01+F7wATOWqeL8zA
ygUuZayPVsY2DKZn4eOr/aiq6M+12M8MUvek70k9vNK7LNnb0EXDcMPz8hmkeOJ5
d7jNiL1xhO1ONHzVZIX45ioOHt9b2nG8E3M8naeIBnArMZ+u5Ny3HCqCQ+aaTYpr
nsqczHENb/56zYKp1zD/GKaq7GO03IsmjdVV4ITOv1BDtdk5nPMwcURRJAmVAH1s
JN+vAAbrtJA/CEEZPIU3NrjrQVE4BeHfCxU0cVINB7hp+dw/SyAIk9PVG29VBC0K
giCrqvcdf/JmgLBvHj3vEznwP9QOMSOXasOvyRTFb98kLiwNaMHkgttbWKRNvKtD
m3rQsLtiJtAIE7BeSXnJvVNRHGFCRhYRZT1Ju9efaO4DKp0o3YtcoSXCEv31rE1k
Y7SOMd+FUjQTDS7t0GI2fw5ZwCzhMOw4hNJn7POaYNNDk99ZgLQ0004X2wqHArhv
ACjA6LS5nlwUlv2tm3ZhtO7DfG0CMu/U1vIA8Q0oJNaa5A7GkBnDFnSFO3OWhWsx
CRzS69b0d/8ddcjCwwbjJCH0VWphSJ4d/VRxGw8Ur3LtNxiCxMMog2GFM2xSNAFn
1tf0LNiS9jmz9+MQX9u6
=1xSn
-----END PGP SIGNATURE-----

--Signature=_Wed__25_Jul_2012_08_42_42_+1000_oOvzmPTfYfh7ObKk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
