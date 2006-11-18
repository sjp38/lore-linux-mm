Date: Sat, 18 Nov 2006 17:27:39 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC 1/7] Remove declaration of sighand_cachep from slab.h
Message-Id: <20061118172739.30538d16.sfr@canb.auug.org.au>
In-Reply-To: <20061118054347.8884.36259.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
	<20061118054347.8884.36259.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__18_Nov_2006_17_27_39_+1100_iHny9hdm0GRxcvSV"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

--Signature=_Sat__18_Nov_2006_17_27_39_+1100_iHny9hdm0GRxcvSV
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 17 Nov 2006 21:43:47 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
>
> Remove declaration of sighand_cachep from slab.h
>
> The sighand cache is only used in fs/exec.c and kernel/fork.c. It is defined
> in kernel/fork.c but also used in fs/exec.c. So add an extern declaration to
> fs/exec.c and remove the definition from slab.h.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> Index: linux-2.6.19-rc5-mm2/fs/exec.c
> ===================================================================
> --- linux-2.6.19-rc5-mm2.orig/fs/exec.c	2006-11-15 16:47:59.065579813 -0600
> +++ linux-2.6.19-rc5-mm2/fs/exec.c	2006-11-17 23:03:46.049603927 -0600
> @@ -62,6 +62,8 @@ int core_uses_pid;
>  char core_pattern[128] = "core";
>  int suid_dumpable = 0;
>
> +extern kmem_cache_t	*sighand_cachep;

Is there no suitable header file to put this in?

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__18_Nov_2006_17_27_39_+1100_iHny9hdm0GRxcvSV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFXqfbFdBgD/zoJvwRAvisAJ4mqq0pRvmrgM4vR9wlBctxrF4zawCePnuY
yKi1N2jaIQ7eVQIvwisAjH4=
=X60e
-----END PGP SIGNATURE-----

--Signature=_Sat__18_Nov_2006_17_27_39_+1100_iHny9hdm0GRxcvSV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
