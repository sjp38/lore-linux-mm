Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 811506B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:09:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a8so3327458pfc.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:09:00 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b4si979949plb.202.2017.10.18.04.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 04:08:59 -0700 (PDT)
Date: Wed, 18 Oct 2017 19:02:08 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 0/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171018110208.GC4352@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <20171017162816.c5751bda5d51d3bf560b8503@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kfjH4zxOES6UT95V"
Content-Disposition: inline
In-Reply-To: <20171017162816.c5751bda5d51d3bf560b8503@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: changbin.du@intel.com, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Morton,
On Tue, Oct 17, 2017 at 04:28:16PM -0700, Andrew Morton wrote:
> On Mon, 16 Oct 2017 17:19:15 +0800 changbin.du@intel.com wrote:
>=20
> > The first one introduce new interfaces, the second one kills naming con=
fusion.
> > The aim is to remove duplicated code and simplify transparent huge page
> > allocation.
>=20
> These introduce various allnoconfig build errors.
Thanks, I will fix and have more test.

--=20
Thanks,
Changbin Du

--kfjH4zxOES6UT95V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ5zSwAAoJEAanuZwLnPNUmI4H/ja8BV3PjCpkZMHQJkoJp6i+
Hu9KbqxodBGSaAfwjg/gYxi15SGx8xSwA5x4AHdI7HdW8CK5FuTkQErbSWz8iTQy
/DFq3/uWu6vg8MYEEWZJDhDg7DjVLaP2MHA1A01dtqN3Djn0pOVrdT52fhayVA+K
Nus1XRIBK+AwFRN1tck1SBc/ubowQadvOrsg7Dpkv5yITgLx/VpXioAObYpTp8HO
VWHTT9kXiKHSgdFkTVnClXFCieJHX86dqV+gcIn54980klH2R0JkCbp0XKWB0yVf
PbqCbU61XZf/1h8HSXxQAuv6p6QdAtxHuSL9C2bkhzII6v6FeuA31c7R9xtklU8=
=alrn
-----END PGP SIGNATURE-----

--kfjH4zxOES6UT95V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
