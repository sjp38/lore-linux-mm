Date: Sat, 18 Nov 2006 17:31:00 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC 5/7] Use external declaration for filep_cachep
Message-Id: <20061118173100.3a8b7293.sfr@canb.auug.org.au>
In-Reply-To: <20061118054408.8884.53656.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
	<20061118054408.8884.53656.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__18_Nov_2006_17_31_00_+1100_m+iwwSudD9HzJ_s="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

--Signature=_Sat__18_Nov_2006_17_31_00_+1100_m+iwwSudD9HzJ_s=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 17 Nov 2006 21:44:08 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
>
> Use external declaration for filep_cachep.
>
> filp_cachep is used in fs/file_table.c. Its defined in fs/dcache.c.
> The easiest solution here is to add an external declaration to
> fs/file_table.c.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> --- linux-2.6.19-rc5-mm2.orig/fs/file_table.c	2006-11-15 16:47:59.622264626 -0600
> +++ linux-2.6.19-rc5-mm2/fs/file_table.c	2006-11-17 23:04:05.885291107 -0600
> @@ -35,6 +35,8 @@ __cacheline_aligned_in_smp DEFINE_SPINLO
>
>  static struct percpu_counter nr_files __cacheline_aligned_in_smp;
>
> +extern kmem_cache_t *filp_cachep;

Is there no suitable header file to put this in?

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__18_Nov_2006_17_31_00_+1100_m+iwwSudD9HzJ_s=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFXqikFdBgD/zoJvwRAjRSAJ9cShMQQ97jhnNr1rK7cijHk2n3EACeLtcI
xRco0p618UnY6sSd/24mZ1c=
=K2LE
-----END PGP SIGNATURE-----

--Signature=_Sat__18_Nov_2006_17_31_00_+1100_m+iwwSudD9HzJ_s=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
