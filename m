Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EB6D76B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 19:35:04 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so4644749pde.7
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 16:35:04 -0800 (PST)
Received: from smtp.gentoo.org (dev.gentoo.org. [2001:470:ea4a:1:214:c2ff:fe64:b2d3])
        by mx.google.com with ESMTPS id q5si10115592pae.56.2014.02.08.16.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Feb 2014 16:35:03 -0800 (PST)
Message-ID: <52F6CD33.80607@gentoo.org>
Date: Sat, 08 Feb 2014 19:34:59 -0500
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com> <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com> <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com> <52F671D0.1060907@gentoo.org> <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com> <52F68299.1040305@gentoo.org> <CALCETrUOPPSb9cOgz1NMqR63Y=kXL1r8nw_WnPyZqTAuweLuaA@mail.gmail.com> <52F68528.30104@gentoo.org> <CALCETrUNgNyMd1CqdmePKxw1+eA-ixKx0=3MvL8Prw7CNOPA9g@mail.gmail.com>
In-Reply-To: <CALCETrUNgNyMd1CqdmePKxw1+eA-ixKx0=3MvL8Prw7CNOPA9g@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="wXEtDWek31gA6pWJMPI1kXrGJIn8hqMoE"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wXEtDWek31gA6pWJMPI1kXrGJIn8hqMoE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 02:54 PM, Andy Lutomirski wrote:
> On Sat, Feb 8, 2014 at 11:27 AM, Richard Yao <ryao@gentoo.org> wrote:
>> On 02/08/2014 02:20 PM, Andy Lutomirski wrote:
>>> Are we looking at the same patch?
>>>
>>> + if (is_vmalloc_or_module_addr(data))
>>> + pages[index++] =3D vmalloc_to_page(data);
>>>
>>> if (is_vmalloc_or_module_addr(data) && !is_vmalloc_addr(data)), the
>>> vmalloc_to_page(data) sounds unhealthy.
>>>
>>> --Andy
>>>
>>
>> Mainline loads all Linux kernel modules into virtual memory. No
>> architecture is known to me where this is not the case.
>>
>=20
> Hmm.  I stand corrected.  vmalloc_to_page is safe on module addresses.
>=20
> --Andy
>=20

I also stand corrected. After you poked me on this, I sent this patch
with a second patch to export is_vmalloc_or_module_addr() to Linus
Torvalds, who wrote is_vmalloc_or_module_addr(). He provided a very
concise explanation why is_vmalloc_addr() is not only safe, but preferabl=
e:

https://lkml.org/lkml/2014/2/8/272

I have resubmitted it with that change. I expect it to be merged soon.


--wXEtDWek31gA6pWJMPI1kXrGJIn8hqMoE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9s05AAoJECDuEZm+6Exk3MAP/3y5XlU0+kMVGHljNaGvZ08L
8RHksmyO8/FB6tdcMU7wTjJ8Ar8ksU+IAo5Bk/dXexEGsUk2e4PQvj9xEoseOCnD
/jDs5TGdRw5nb52SwWVRWy1/uFXQwB5y4GJqbpOcxmYwXxib7Y/e7J3+UxobKQVe
LImtVecNeIDdl7E0ZCxW5tmOrayxC3Zt2d0xt1kGUZNRISFGXJgORYGanpNcXf+p
OT3+YZHd2mJQwOB9xR0YetxFNUOYdCwt04R+eKqvLi4hd5cE2veYOwHaPO/8TREv
nhbFhZStKC4Ymd/PyQLqvrfIVb0fxtbTzRKLnnPnUmrkxcVS+gtpkdRYN1PNdyJp
y+8aIWFbQcHEs+5TKrKW3TdI+SZLk3Jd0oIYPyuodKGWSLHXUPly5RYwqxeKI0M3
zSw4uQjKdGCL79omwBEBpyGLZrv+P/r2yu/hSjSJHx1idLJaGAdOgajCQtB6cVdf
KSJ6tEGC14rsBY2qa3H3dKd7Ag4ilwYkDpgTuSTU1LiXhWfsvY3QEsYrBIUAXtA6
RLbyqDkKFtXkQzEUjMU6XWwW+mqbSzwpntra8/R8QGt6MAT0j9z/p0NyvLfu4UMN
5I/L4GLwHDaP4Up5o11BkTrTlPWfXbxucwEbTJpBUbhrmI+YTNkceoVrHy+Mt7kw
QIjST0nmy+RjBRxyCe/6
=9u6t
-----END PGP SIGNATURE-----

--wXEtDWek31gA6pWJMPI1kXrGJIn8hqMoE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
