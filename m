Date: Sat, 18 Nov 2006 17:32:53 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC 6/7] Use an external declaration in exit.c for fs_cachep
Message-Id: <20061118173253.85d5b7e8.sfr@canb.auug.org.au>
In-Reply-To: <20061118054413.8884.99940.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
	<20061118054413.8884.99940.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__18_Nov_2006_17_32_53_+1100_wgt1Dw/gzvbUc.K/"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

--Signature=_Sat__18_Nov_2006_17_32_53_+1100_wgt1Dw/gzvbUc.K/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 17 Nov 2006 21:44:13 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
>
> Use an external declaration in exit.c for fs_cachep.
>
> fs_cachep is only used in kernel/exit.c and in kernel/fork.c.
> It is defined in kernel/fork.c so we need to add an external
> declaration to kernel/exit.c to be able to avoid the
> declaration.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> --- linux-2.6.19-rc5-mm2.orig/kernel/exit.c	2006-11-15 16:48:11.485511089 -0600
> +++ linux-2.6.19-rc5-mm2/kernel/exit.c	2006-11-17 23:04:09.764530373 -0600
> @@ -48,6 +48,8 @@
>  #include <asm/pgtable.h>
>  #include <asm/mmu_context.h>
>
> +extern kmem_cache_t *fs_cachep;

You know what I am going to say, right? :-)

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__18_Nov_2006_17_32_53_+1100_wgt1Dw/gzvbUc.K/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFXqkVFdBgD/zoJvwRAqafAJ41e/qDDpNgAYbe5l9L+coXmNaliwCdFZhh
M3/5ahSQ7XdwYP76gzEn4eM=
=FC8L
-----END PGP SIGNATURE-----

--Signature=_Sat__18_Nov_2006_17_32_53_+1100_wgt1Dw/gzvbUc.K/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
