Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA916B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 00:27:18 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s68so141556117qkb.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 21:27:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o201si10349192qka.229.2016.05.18.21.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 21:27:17 -0700 (PDT)
Message-ID: <1463632033.16365.45.camel@redhat.com>
Subject: Re: [PATCH] mm: make faultaround produce old ptes
From: Rik van Riel <riel@redhat.com>
Date: Thu, 19 May 2016 00:27:13 -0400
In-Reply-To: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-0rnzZ3DHAZJ6q0C4zdBQ"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Minchan Kim <minchan@kernel.org>


--=-0rnzZ3DHAZJ6q0C4zdBQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-17 at 15:32 +0300, Kirill A. Shutemov wrote:
> Currently, faultaround code produces young pte. This can screw up
> vmscan
> behaviour[1], as it makes vmscan think that these pages are hot and
> not
> push them out on first round.
>=20
> Let modify faultaround to produce old pte, so they can easily be
> reclaimed under memory pressure.
>=20
> This can to some extend defeat purpose of faultaround on machines
> without hardware accessed bit as it will not help up with reducing
> number of minor page faults.
>=20
> We may want to disable faultaround on such machines altogether, but
> that's subject for separate patchset.
>=20
> [1] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmeno
> n@codeaurora.org
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vinayak Menon <vinmenon@codeaurora.org>
> Cc: Minchan Kim <minchan@kernel.org>
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-0rnzZ3DHAZJ6q0C4zdBQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXPUChAAoJEM553pKExN6DR8UH/2GVMDnYhoit2+qziDhfhefJ
ynHlfPUrf9Yk9xnjkKbOcqrpxdnyc/RuvOdpZ6t/To7nHgYjM+sIFj9HHISJIkX2
GwHD/s+fMmJ7eY6QAVLyMrDggH3vpQ66aNzWyTSyjayvuSj66WsvUEeN+gxqg8W/
JrneMdZcKvDlX+kmOXAhVapTbbg3ByDWwqcfffU42DNK5WM5PRoXZDI7oaGG415d
zTdPp7PcllW5FmY3KBWWjEJc7bNbOlO1du0cbtr1nkPLBIhj4C81qCIV68a1De2z
4+8gBoj47DqN7Ow2gGmROIInReXDmtcXtYd4VC1JvfKhD2hX3s/clnfH5nifKQY=
=EZyh
-----END PGP SIGNATURE-----

--=-0rnzZ3DHAZJ6q0C4zdBQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
