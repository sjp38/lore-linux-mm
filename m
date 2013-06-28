Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2CD0B6B003B
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 21:10:06 -0400 (EDT)
Date: Fri, 28 Jun 2013 11:09:55 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-06-27-16-36 uploaded
Message-Id: <20130628110955.31ccbb49fa088c35449e7741@canb.auug.org.au>
In-Reply-To: <20130627173225.3915d976.akpm@linux-foundation.org>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com>
	<20130628095712.120bec7036284584fd467ee2@canb.auug.org.au>
	<20130627173225.3915d976.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Jun_2013_11_09_55_+1000_cXkpIKyeQqXMe3y="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Fri__28_Jun_2013_11_09_55_+1000_cXkpIKyeQqXMe3y=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 27 Jun 2013 17:32:25 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Fri, 28 Jun 2013 09:57:12 +1000 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
>=20
> > On Thu, 27 Jun 2013 16:37:33 -0700 akpm@linux-foundation.org wrote:
> > >
> > >   include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
> > >   arch-c6x-mm-include-asm-uaccessh-to-pass-compiling.patch
> > >   drivers-dma-pl330c-fix-locking-in-pl330_free_chan_resources.patch
> >=20
> > Did you mean to drop these three patches from linux-next?
>=20
> Nope, they should be inside the NEXT_PATCHES_START/NEXT_PATCHES_END
> section, thanks.

OK, I shoved them back in (in akpm-current).  One note:

$ git am ../../mmotm/text/broken-out/arch-c6x-mm-include-asm-uaccessh-to-pa=
ss-compiling.patch
Applying: arch: c6x: mm: include "asm/uaccess.h" to pass compiling
Warning: commit message did not conform to UTF-8.
You may want to amend it after fixing the message, or set the config
variable i18n.commitencoding to the encoding your project uses.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__28_Jun_2013_11_09_55_+1000_cXkpIKyeQqXMe3y=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRzOJoAAoJEECxmPOUX5FEdAYQAIXi7IRkHn/5XDZvU5lFkNX+
I4yx2oNJmmeJtgL+4Akf8kJX1rKMhaExQC/9DW9m2AsiWxsGV8jcpnftWW3PdWi8
gVmTOsZfbemmoyQ60YZrMZotHwY4/vPXrSCZiR4ZaJvlz8ctuiWLY+Pfvz4n1nCM
Ckjb9Ji3cA+7Qn844htiE0bnA7Oql+c1b9mSyGRvvcgvPHuBSzMD+w6pXjFP7aeT
dXm1BxILe0GcRnIXZM667taerV/Cmvh4AAHrALzed7acReal/Y0uc+KRSxkFC0TN
UiLY/kCQItE9lD21pdDSMk/RtFn5OFSpT4LSNln3yVX9npKbdpxdviszbjumMV6+
dKERM1sgnbYBsxkgk1eXAsNx1/OgBKPUpjVmzplK1dcJdBiQuwJk5+o5kMkWNygh
ER9+j/kyQQNWV37OxYtcup0oWjAnf5qretEcMDOk9rz7MJiOeGqaEsgW9kBpjvrt
6CNsK8mxympe2IwCF3i/mgO6pypkBzMoVwDfuOEUIfPl7JCsMzlQfYkEt7afZD3Y
NthhGZ09oLfn6IO08C71lQe3fdkAxbShQsa5yuSb2SzkTAXTsw9LwpBSTapakT+c
AF/1HzjRV29A9K63OI6+9TWkUfLDJF+Rfr5mKLB1l01ZG7JOI4EcwWYnEn7Ye6lO
r4Rdynj/NtzPqILuD/SO
=49A8
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Jun_2013_11_09_55_+1000_cXkpIKyeQqXMe3y=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
