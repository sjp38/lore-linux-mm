Date: Wed, 23 May 2007 17:07:36 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 3/8] Generic Virtual Memmap support for SPARSEMEM V4
Message-Id: <20070523170736.260d1b22.sfr@canb.auug.org.au>
In-Reply-To: <Pine.LNX.4.64.0705222214590.5218@schroedinger.engr.sgi.com>
References: <exportbomb.1179873917@pinky>
	<E1HqdKD-0003dU-5r@hellhawk.shadowen.org>
	<Pine.LNX.4.64.0705222214590.5218@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__23_May_2007_17_07_36_+1000_Qe3UP.g.beyBxc.B"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__23_May_2007_17_07_36_+1000_Qe3UP.g.beyBxc.B
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Tue, 22 May 2007 22:15:26 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
>
> I get a couple of warnings:
>
> mm/sparse.c:423: warning: '__kmalloc_section_memmap' defined but not used
> mm/sparse.c:453: warning: '__kfree_section_memmap' defined but not used

This is fixed by my patch "Move three functions that are only needed for
CONFIG_MEMORY_HOTPLUG" which I posted yesterday and is in Andrew's tree.
Sorry for not cc'ing linux-mm.
--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__23_May_2007_17_07_36_+1000_Qe3UP.g.beyBxc.B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGU+hBFdBgD/zoJvwRAltZAJ9UIEYzmqu39rUL/Vy2D8R1VurL+gCgocEl
JwYPlmoTH/9Q8f430I9HbXc=
=x+wh
-----END PGP SIGNATURE-----

--Signature=_Wed__23_May_2007_17_07_36_+1000_Qe3UP.g.beyBxc.B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
