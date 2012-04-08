Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4944B6B0044
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 16:30:37 -0400 (EDT)
Message-ID: <4F81F564.3020904@nod.at>
Date: Sun, 08 Apr 2012 22:30:28 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: swapoff() runs forever
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC5366DC4EF9D255FD0AF3754"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, paul.gortmaker@windriver.com, Andrew Morton <akpm@linux-foundation.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC5366DC4EF9D255FD0AF3754
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi!

I'm observing a strange issue (at least on UML) on recent Linux kernels.
If swap is being used the swapoff() system call never terminates.
To be precise "while ((i =3D find_next_to_unuse(si, i)) !=3D 0)" in try_t=
o_unuse()
never terminates.

The affected machine has 256MiB ram and 256MiB swap.
If an application uses more than 256MiB memory swap is being used.
But after the application terminates the free command still reports that =
a few
MiB are on my swap device and swappoff never terminates.

Here some numbers:
root@linux:~# free
             total       used       free     shared    buffers     cached=

Mem:        255472      13520     241952          0        312       7080=

-/+ buffers/cache:       6128     249344
Swap:       262140      17104     245036
root@linux:~# cat /proc/meminfo
MemTotal:         255472 kB
MemFree:          241952 kB
Buffers:             312 kB
Cached:             7080 kB
SwapCached:            0 kB
Active:             3596 kB
Inactive:           6076 kB
Active(anon):       1512 kB
Inactive(anon):      848 kB
Active(file):       2084 kB
Inactive(file):     5228 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        262140 kB
SwapFree:         245036 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:          2296 kB
Mapped:             1824 kB
Shmem:                80 kB
Slab:               2452 kB
SReclaimable:       1116 kB
SUnreclaim:         1336 kB
KernelStack:         192 kB
PageTables:          556 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      389876 kB
Committed_AS:     238412 kB
VmallocTotal:    3788784 kB
VmallocUsed:          68 kB
VmallocChunk:    3788716 kB

What could cause this issue?
I'm not sure whether this is UML specific or not.
Maybe only UML is able to trigger the issue...

Thanks,
//richard


--------------enigC5366DC4EF9D255FD0AF3754
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPgfVlAAoJEN9758yqZn9emQ0H/2ldqm+CUGOd3cNvazaGJhQl
AchUlj/lsgDcuMrW7RZC+IDTRDjmWoyUgrMr9WXyQ1bMNu1CDiB9vsunGqn3ROyq
Mp0zQPqg0OCfQWMLmW2Je5/jjxQVk4myYCUZp0KIKUHG9tK/LiyQE7PsOr3Mi6EI
VtBsdjO8Y0Ka++fZBE0tsv16Ok9QJd5GovxSm9w+djAXV1wxK7Lc71JFMx+w5Fi0
B5lZHQHUQ/RgKEH8qT4Q7TqX1BIY/xoFS8Wo5bQnML5PzTzLdlaX0x7/ExWrDGj4
j3OwN3wKqBz2+7wf7+9MQ8jv5jpDCwS+pYr2gBt8u/5pughFh3xsB6sjWEHAbfw=
=6Wvw
-----END PGP SIGNATURE-----

--------------enigC5366DC4EF9D255FD0AF3754--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
