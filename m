Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 73E8F6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 16:33:53 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f105so22585300qge.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 13:33:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q196si3422568qha.43.2016.04.06.13.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 13:33:52 -0700 (PDT)
Message-ID: <1459974829.28435.6.camel@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
From: Rik van Riel <riel@redhat.com>
Date: Wed, 06 Apr 2016 16:33:49 -0400
In-Reply-To: <1447181081-30056-2-git-send-email-aarcange@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
	 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Z5cNlTHiW6Jw5GTxWqiV"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>


--=-Z5cNlTHiW6Jw5GTxWqiV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-11-10 at 19:44 +0100, Andrea Arcangeli wrote:
> Without a max deduplication limit for each KSM page, the list of the
> rmap_items associated to each stable_node can grow infinitely
> large.
>=20
> During the rmap walk each entry can take up to ~10usec to process
> because of IPIs for the TLB flushing (both for the primary MMU and
> the
> secondary MMUs with the MMU notifier). With only 16GB of address
> space
> shared in the same KSM page, that would amount to dozens of seconds
> of
> kernel runtime.

Silly question, but could we fix this problem
by building up a bitmask of all CPUs that have
a page-with-high-mapcount mapped, and simply
send out a global TLB flush to those CPUs once
we have changed the page tables, instead of
sending out IPIs at every page table change?

--=20
All rights reversed

--=-Z5cNlTHiW6Jw5GTxWqiV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJXBXKtAAoJEM553pKExN6DXasIAJ7STrI+JVrogVriiXP7sNB+
H/odmLSyLCPQkAg/a+9GpyoqrJ+ouk4rRT+HiP3DtrJ7+0od4BC+iHMuTDo+Hw6x
vMefL4k0NhKgiHPqsEXvmitNxZEz4bhJpkVXvEr+KBuZm39iTSvmHZNjWqA30UO7
FdWwNNGt5N310/hSPc26G4U1Qa3TyuUJHleThNQEdTTzX8YTjqR8wciLbKaSTIB1
Rt+eNwziiR9Im4ZXsHpFLaD3MWAkqSmJuRBQgUpHjQr5zWMz3aOJvUgjKkW5LDBe
UeV54ZS5QoSL3tVLaqpGxIXjykPm3pJ+LWNjLJHaUiSI0brt6CXkKft67uPvVNE=
=CdDD
-----END PGP SIGNATURE-----

--=-Z5cNlTHiW6Jw5GTxWqiV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
