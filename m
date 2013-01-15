Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D8B126B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 15:58:11 -0500 (EST)
Date: Tue, 15 Jan 2013 14:11:02 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [next-20130114] Call-trace in LTP (lite) madvise02 test
 (block|mm|vfs related?)
Message-Id: <20130115141102.9a7d93cf4ea74c759ff9e9d5@canb.auug.org.au>
In-Reply-To: <CA+icZUV_dz2Bvu6o=YRFu6324ccVr1MaOEpRcw0rguppR5rQQg@mail.gmail.com>
References: <CA+icZUW1+BzWCfGkbBiekKO8b6KiyAiyXWAHFmVUey2dHnSTzw@mail.gmail.com>
	<50F454C2.6000509@kernel.dk>
	<CA+icZUX_uKSzvdhd4tMtgb+vUxqC=fS7tfSHhs29+xD_XQQjBQ@mail.gmail.com>
	<CA+icZUV_dz2Bvu6o=YRFu6324ccVr1MaOEpRcw0rguppR5rQQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__15_Jan_2013_14_11_02_+1100_w6gVzq1PqO4u0VtS"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Jens Axboe <axboe@kernel.dk>, linux-next <linux-next@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Sasha Levin <sasha.levin@oracle.com>, Roland McGrath <roland@hack.frob.com>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>linux-mm@kvack.org

--Signature=_Tue__15_Jan_2013_14_11_02_+1100_w6gVzq1PqO4u0VtS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 14 Jan 2013 22:09:18 +0100 Sedat Dilek <sedat.dilek@gmail.com> wrot=
e:
>
> Looks like this is the fix from Sasha [1].
> Culprit commit is [2].
> Testing...
>=20
> - Sedat -
>=20
> [1] https://patchwork.kernel.org/patch/1973481/

OK, I added this patch ("mm: fix BUG on madvise early failure") to the
copy of the akpm tree in linux-next today.

> [2] http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3Dc=
ommitdiff;h=3D0d18d770b9180ffc2c3f63b9eb8406ef80105e05

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__15_Jan_2013_14_11_02_+1100_w6gVzq1PqO4u0VtS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ9MjGAAoJEECxmPOUX5FEyiwP/iUPiDLhrB9odcNNNsEYQbp3
Vvp6bLHI3OtapG0gEd87Nrfnp5ITIwN7MjSGeF6rcx7eS9Kxaz6ZgO/zzvqDdzim
ND5jDlSUR7btkO5ygWJIjXLxTV1RhBA6j8hLElVoMfEc6V2lY7ZBP8H2ONegr+uJ
TcJTj7Cw4yFXNpPL5RN8C1RkRG8CBIv/IoaZsp609Ylnf0s8gvPF0TkxojasEM0D
qj68MURnOWSmI6DSI2B4UMonhA1Uz83ea0AKSXKt+mB/ii+7LWyFxWI8iG1VJYwa
tt58xtCrpgk7nYwHg2SyfExbeUc3OZKDXKlr/CHSRqJRGl8t1gbPfYfGUEyKaZho
AhUWGM5PTm/9Hsv+AcpKLEzFovM/Ne5xzIM6Ye6LXDesWI+Ys6IRlnPrZts5MKot
fK8lbbrYZZPVLPyVogEOe/OPnBLBTH52CGhywbiNNrR7v1FLuNtIHI9sxsxGa597
k1H52HWg/n/W3uzPbvHBtN4hzSa0dyBT1+ExqlNUT5hi6z79nxehPGdY+ZANhIy2
zrvsyFAAkumUTjg/dJ/mDKIosaB7S9TLdD57op1Ycavvw/VPbjCJC4TnqRAJTzyY
8LeCp1EA4iWcHXruxgf/qQHrrSCocnWNs5AxKooACjMo8PZQcheg7T37E3qvH8h5
l+rKyyqdg4elUEZ1/Zle
=d6nH
-----END PGP SIGNATURE-----

--Signature=_Tue__15_Jan_2013_14_11_02_+1100_w6gVzq1PqO4u0VtS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
