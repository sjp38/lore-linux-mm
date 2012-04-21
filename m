Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1378E6B004D
	for <linux-mm@kvack.org>; Sat, 21 Apr 2012 14:13:26 -0400 (EDT)
Date: Sat, 21 Apr 2012 14:13:20 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/11] Swap-over-NFS without deadlocking V3
Message-ID: <20120421181320.GB17039@mgebm.net>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IrhDeMKUP4DT/M7F"
Content-Disposition: inline
In-Reply-To: <1334578675-23445-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>


--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Apr 2012, Mel Gorman wrote:

> Changelog since V2
> o Nothing significant, just rebases. A radix tree lookup is replaced with
>   a linear search would be the biggest rebase artifact
>=20
> This patch series is based on top of "Swap-over-NBD without deadlocking v=
9"
> as it depends on the same reservation of PF_MEMALLOC reserves logic.
>=20
> When a user or administrator requires swap for their application, they
> create a swap partition and file, format it with mkswap and activate it w=
ith
> swapon. In diskless systems this is not an option so if swap if required
> then swapping over the network is considered.  The two likely scenarios
> are when blade servers are used as part of a cluster where the form factor
> or maintenance costs do not allow the use of disks and thin clients.
>=20
> The Linux Terminal Server Project recommends the use of the Network
> Block Device (NBD) for swap but this is not always an option.  There is
> no guarantee that the network attached storage (NAS) device is running
> Linux or supports NBD. However, it is likely that it supports NFS so there
> are users that want support for swapping over NFS despite any performance
> concern. Some distributions currently carry patches that support swapping
> over NFS but it would be preferable to support it in the mainline kernel.
>=20
> Patch 1 avoids a stream-specific deadlock that potentially affects TCP.
>=20
> Patch 2 is a small modification to SELinux to avoid using PFMEMALLOC
> 	reserves.
>=20
> Patch 3 adds three helpers for filesystems to handle swap cache pages.
> 	For example, page_file_mapping() returns page->mapping for
> 	file-backed pages and the address_space of the underlying
> 	swap file for swap cache pages.
>=20
> Patch 4 adds two address_space_operations to allow a filesystem
> 	to pin all metadata relevant to a swapfile in memory. Upon
> 	successful activation, the swapfile is marked SWP_FILE and
> 	the address space operation ->direct_IO is used for writing
> 	and ->readpage for reading in swap pages.
>=20
> Patch 5 notes that patch 3 is bolting
> 	filesystem-specific-swapfile-support onto the side and that
> 	the default handlers have different information to what
> 	is available to the filesystem. This patch refactors the
> 	code so that there are generic handlers for each of the new
> 	address_space operations.
>=20
> Patch 6 adds an API to allow a vector of kernel addresses to be
> 	translated to struct pages and pinned for IO.
>=20
> Patch 7 updates NFS to use the helpers from patch 3 where necessary.
>=20
> Patch 8 avoids setting PF_private on PG_swapcache pages within NFS.
>=20
> Patch 9 implements the new swapfile-related address_space operations
> 	for NFS and teaches the direct IO handler how to manage
> 	kernel addresses.
>=20
> Patch 10 prevents page allocator recursions in NFS by using GFP_NOIO
> 	where appropriate.
>=20
> Patch 11 fixes a NULL pointer dereference that occurs when using
> 	swap-over-NFS.
>=20
> With the patches applied, it is possible to mount a swapfile that is on an
> NFS filesystem. Swap performance is not great with a swap stress test tak=
ing
> roughly twice as long to complete than if the swap device was backed by N=
BD.
>=20


FWIW, I'd like to see these go in, I use them for giving ARM boards with NFS
root file systems swap space.

I have tested these with an artificial swap benchmark and with a large proj=
ect
compile on a beagle board.  They work great for me.

Tested-by: Eric B Munson <emunson@mgebm.net>

--IrhDeMKUP4DT/M7F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPkvi/AAoJEKhG9nGc1bpJYbwQAITu8HJ3ZbrL45B04NMr5tJ9
T/TerHIoKfr7Wdi08GCNckJzTY8GzLNvWEsENnHIixtSkkvyBc1sOHVeBogrlUj3
ZZOe30G4bhIwjfiUaN7PHJ2rSjlKby42qyLJ7gttY7uluuwNgA42gyobsByUxObx
ps3OC6NwK8dw5r6DUqYYJnuTZVVYH42prPkk4hB3pUtTpGTQnofLbDoVHpHQyzDl
5HoDoyeblNJgX1DX8g8qcEffiecOdpzN7TmYxvNMPk/w5SJC0TT/TDXVDhXMFoXq
B85v3khDAuhZxtaIHUguL/JYRbtkqHDnzbBJLHe91AP8/IRx3C+aWvn3ekOJqLyt
sXJ3ASingmiAqzCsnMOVcuJcQWKLU8o16U3w/BCqIatrHS1IaQbOi+UZbaQ1Y5+c
kqmAyNRTFF7KtHicTouPkx8WVF0qgwfhw5BNlG5tiVRNWjumc2Kojkhdx32jpQOc
kdrH9kOpeXB0iI+BuF4iBUqhUPlFuasD0Cx1QNKOSFICI6jO5QaBEFv+sS7TOOJa
5fJINHIgOM4nZZBR+rjwo4B+/mHpOc2fG/gQGg5Dr2Ad0Crwf4eTEFclB+zmOawK
hj6la0vVaQUOwJZbUWIV/+ubYqr9Fs2Jy2/wOmEOSF9UaMcx7+BQKlUnptdQvofh
YxG1SgEuq8gcM2ax9BN7
=XfAk
-----END PGP SIGNATURE-----

--IrhDeMKUP4DT/M7F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
