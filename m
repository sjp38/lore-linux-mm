From: Sascha Silbe <x-linux@infra-silbe.de>
Subject: Re: [v3,6/9] mm/page_owner: use stackdepot to store stacktrace
Date: Wed, 26 Oct 2016 15:06:05 +0200
Message-ID: <toe60ofdzuq.fsf@twin.sascha.silbe.org>
References: <1466150259-27727-7-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466150259-27727-7-git-send-email-iamjoonsoo.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
List-Id: linux-mm.kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dear Joonsoo,

Joonsoo Kim <js1304@gmail.com> writes:

> Currently, we store each page's allocation stacktrace on corresponding
> page_ext structure and it requires a lot of memory.  This causes the
> problem that memory tight system doesn't work well if page_owner is
> enabled.  Moreover, even with this large memory consumption, we cannot get
> full stacktrace because we allocate memory at boot time and just maintain
> 8 stacktrace slots to balance memory consumption.  We could increase it to
> more but it would make system unusable or change system behaviour.
[...]

This patch causes my Wandboard Quad [1] not to boot anymore. I don't get
any kernel output, even with earlycon enabled
(earlycon=3Dec_imx6q,0x02020000). git bisect pointed towards your patch;
reverting the patch causes the system to boot fine again. Config is
available at [2]; none of the defconfigs I tried (defconfig =3D
multi_v7_defconfig, imx_v6_v7_defconfig) works for me.

Haven't looked into this any further so far; hooking up a JTAG adapter
requires some hardware changes as the JTAG header is unpopulated.

Sascha

PS: Please CC me on replies; I'm not subscribed to any of the lists.

[1] http://www.wandboard.org/index.php/details/wandboard
[2] https://sascha.silbe.org/tmp/config-4.8.4-wandboard-28-00003-g9e9b5d6
=2D-=20
Softwareentwicklung Sascha Silbe, Niederhofenstra=C3=9Fe 5/1, 71229 Leonberg
https://se-silbe.de/
USt-IdNr.: DE281696641

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJYEKo9AAoJEMGPauiBMO2XKwIP/3hm2XEsefEpUL/WKb+2M4Ch
MLoJsnjHXFuDuXiw77UHkezGUhReSIcnoF6WotnazX5Y56ojTTEwScH4LrbKfJ1D
jphKAPNpWmB68s3mh6oNHkKT4SjaXY70KZZI6rbq/JzXNyizu2i9i6AApgcmlW2H
DgQPE5EUn9Y+tLjmA/9gvk3eLOKybfvrDMy6BfMkMP74RNuy2fvdLWhsxi7J/uIF
uxj5L7MufZvImSpzdVjwDqsVTsJ4mGocpeQUmRrKS3nddPqTLz16nBfMjiEYedCR
0PIDBpxajdPshQK5Y4HxzUvuPStoP4voxYdukv7n7UVliwhihUDUVC9iV/2BHNvW
XK9tTYcYIjXDhdOIb2+6Fpgbbd2eBPNyOJmjma/CvqlShr8koGt2OVpBnZVQxis6
7LQEcDC7uDbIvDsJowbM9xZKYTGHsekIkPT5SX1t+QE6xf5Iacm+gOgWlM2WEvqr
APWtUK6q4+cVw9nY24rRhwbJyF84j6Nqb7akGfNjgGoOuaaDMSWUVcvOS2KPX8Zu
UpjdoVMycQ3E3QrKO8pIZYWtOJ9NZeaHPxjS25Go5b+G+bALse5A09v6Fj/dEqsI
SwCA6ZTCvj2/X1TLLwmwzmsU0YJGSwgfv6ljD+uAxxl1wdr3BFMkiIK4S/r2H8mX
UWCwrCbV7o+wcQiWWkBT
=o5qU
-----END PGP SIGNATURE-----
--=-=-=--
