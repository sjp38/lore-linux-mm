Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 617626B0069
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 17:09:47 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h15so2723216igd.4
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 14:09:47 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id fu3si4351229igd.37.2014.10.02.14.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 14:09:46 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id rp18so3391279iec.27
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 14:09:45 -0700 (PDT)
Message-ID: <542DBF13.6000305@gmail.com>
Date: Thu, 02 Oct 2014 17:09:39 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: add mremap flag for preserving the old mapping
References: <1412052900-1722-1-git-send-email-danielmicay@gmail.com> <CALCETrX6D7X7zm3qCn8kaBtYHCQvdR06LAAwzBA=1GteHAaLKA@mail.gmail.com> <542A79AF.8060602@gmail.com> <CALCETrVHgvhAN3neoOpJEk94uM7QKm2izZpp+=1UA6qieaQiTQ@mail.gmail.com>
In-Reply-To: <CALCETrVHgvhAN3neoOpJEk94uM7QKm2izZpp+=1UA6qieaQiTQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="PRlCVIkmvMIs5cCoIexuIIqIjW92QRa2D"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jason Evans <jasone@canonware.com>, Linux API <linux-api@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PRlCVIkmvMIs5cCoIexuIIqIjW92QRa2D
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 30/09/14 01:49 PM, Andy Lutomirski wrote:
>=20
> I think it might pay to add an explicit vm_op to authorize
> duplication, especially for non-cow mappings.  IOW this kind of
> extension seems quite magical for anything that doesn't have the
> normal COW semantics, including for plain old read-only mappings.

Adding a vm_ops table to MAP_PRIVATE|MAP_ANONYMOUS mappings has a
significant performance impact. I haven't yet narrowed it down, but
there's at least one code path a check of `!vma->vm_ops` for the fast
path. One is for transparent huge page faults, so the performance impact
makes sense. I'll use a simpler implementation for now since the
requirements are very narrow / simple.


--PRlCVIkmvMIs5cCoIexuIIqIjW92QRa2D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJULb8WAAoJEPnnEuWa9fIqSNAP/A7LCl/XGzXIE2tl5P6OOodp
oTI8okG15yxG4jXYOH7dT5//3qdvkeU5mU86/IOde+qmts2i5W+wNnM1rYHyOZka
hil/u1vF3flo+SiI47r9alh2JOyS7Yl51VFNQZ2ExIX9eUdAAahhdASCAQDia/D8
bITv3Z5XSGPRCxglo6vUYjRgv1l9Hrx+riwcwe9ceyNFx6Q7dD9/FzDs0nAu4Oy7
45caIcaVlBUpKiyhjwWFYF3wFO1J3LTC6zJyaA1TkbCTC5mbokGMDO6ghvGrzLE7
/jZIxJdsoNp3ifjgXlRg+9nO3UAP3LwsueHJlWuC2Xn5iNq9XNWyvxSvtWND/30d
TMwLS4ox1UFfd3TQhla100j2h0kAJECL+l2Rm61uNWlwN3+SdnzhLNHN9nKC2gAA
uuhFaM+jNWwSjN3d8NMM2L01eZZi1Fy18jcb/iGEDAZ3O83rYBIGy2WZJTJVQOnc
xjxyQl7NuBLugIUAkSC5OqJGEQ84ur56wX1HmlRbV7sdd8bbpNuXQS3qZuoY+p8H
fQSCW3w4hJ8mQBS4l5MZ/Oc44XuNNdQbEzL60Af0uxQbC46C83tJyqOUHKLysKnH
7lnEsm7tIXtisw5mg9blovJUSOZ5ZL5MshD0kdSLjkPUhjXm5bBJFsC3b2MsmI/A
MUa1auMJAdsi3LBa3uw6
=mK1z
-----END PGP SIGNATURE-----

--PRlCVIkmvMIs5cCoIexuIIqIjW92QRa2D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
