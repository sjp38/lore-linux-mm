Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 41F336B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:36:43 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so552439lag.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:36:41 -0700 (PDT)
Date: Fri, 19 Oct 2012 23:36:32 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121019233632.26cf96d8@sacrilege>
In-Reply-To: <20121019205055.2b258d09@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/wxyGE5+196dRa2ziL0/owlO"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: paul@paul-moore.com, netdev@vger.kernel.org

--Sig_/wxyGE5+196dRa2ziL0/owlO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 19 Oct 2012 20:50:55 +0600
Mike Kazantsev <mk.fraggod@gmail.com> wrote:

> slabtop showed "kmalloc-64" being the 99% offender in the past, but
> with recent kernels (3.6.1), it has changed to "secpath_cache"

To be more specific, on 3.5.4 kernel leak looks like this:

 Active / Total Objects (% used)    : 19971419 / 20084060 (99.4%)
 Active / Total Slabs (% used)      : 318645 / 318645 (100.0%)
 Active / Total Caches (% used)     : 79 / 121 (65.3%)
 Active / Total Size (% used)       : 1285299.85K / 1307992.83K (98.3%)
 Minimum / Average / Maximum Object : 0.01K / 0.06K / 8.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                =
  =20
19678272 19678272 100%    0.06K 307473       64   1229892K kmalloc-64      =
      =20
159198  95262  59%    0.10K   4082       39     16328K buffer_head         =
  =20
 32865  17515  53%    0.19K   1565       21      6260K dentry              =
  =20
 20480  19456  95%    0.02K     80      256       320K ext4_io_page        =
  =20
 16896  10380  61%    0.03K    132      128       528K kmalloc-32          =
  =20
 16164  16164 100%    0.11K    449       36      1796K sysfs_dir_cache     =
  =20
 15980  15980 100%    0.02K     94      170       376K fsnotify_event_holde=
r =20
 14742   9205  62%    0.87K    819       18     13104K ext4_inode_cache    =
  =20
 13916   5494  39%    0.55K    497       28      7952K radix_tree_node     =
  =20
 10030   5172  51%    0.05K    118       85       472K anon_vma_chain      =
  =20
 10020  10020 100%    0.13K    334       30      1336K ext4_allocation_cont=
ext
  9486   9398  99%    0.04K     93      102       372K Acpi-Namespace      =
  =20
  8192   8192 100%    0.01K     16      512        64K kmalloc-8           =
  =20
  6960   6016  86%    0.25K    435       16      1740K kmalloc-256         =
  =20
  6641   5412  81%    0.55K    229       29      3664K inode_cache         =
  =20
  5124   4333  84%    0.19K    244       21       976K kmalloc-192

Unfortunately, kernel on this machine isn't booted with slub_debug
options (yet), so there're no specific on whether it's allocated (as I
understand it) in the same call or a different one.

Not sure if it's even possible that it might be the same call.


--=20
Mike Kazantsev // fraggod.net

--Sig_/wxyGE5+196dRa2ziL0/owlO
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCBj6MACgkQASbOZpzyXnEUngCg288WL8R2Vni+/OOxbGFccXDD
qaEAoINK1cBF9E1X5WWOhbs+VBP6mufe
=TRf2
-----END PGP SIGNATURE-----

--Sig_/wxyGE5+196dRa2ziL0/owlO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
