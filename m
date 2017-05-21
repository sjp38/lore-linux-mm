Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC9AD280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 05:56:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y106so11121425wrb.14
        for <linux-mm@kvack.org>; Sun, 21 May 2017 02:56:56 -0700 (PDT)
Received: from pokefinder.org (sauhun.de. [88.99.104.3])
        by mx.google.com with ESMTP id q201si16074615wmg.20.2017.05.21.02.56.55
        for <linux-mm@kvack.org>;
        Sun, 21 May 2017 02:56:55 -0700 (PDT)
Date: Sun, 21 May 2017 11:56:54 +0200
From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: zswap: Delete an error message for a failed memory allocation in
 zswap_dstmem_prepare()
Message-ID: <20170521095654.bzpaa2obfszrajgb@ninjato>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
 <20170521084734.GB1456@katana>
 <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="2fw5crfd3oxs2lrd"
Content-Disposition: inline
In-Reply-To: <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org


--2fw5crfd3oxs2lrd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Markus,

> > Markus, can you please stop CCing me on every of those patches?
>=20
> Yes, of course.

Thanks!

> >> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ1=
6-Refactor_Strings-WSang_0.pdf
>=20
> Did I interpret any information from your presentation slides in an
> inappropriate way?

Have you read my LWN article "Best practices for a big patch series"?

https://lwn.net/Articles/585782/

> > And why do you create a patch for every occasion in the same file?
>=20
> This can occasionally happen when I am more unsure about the change accep=
tance
> for a specific place.

Why were you unsure here?

> This can also happen as a side effect if such a source code search pattern
> will point hundreds of places out for further software development consid=
erations.
> How would you prefer to clarify the remaining update candidates there?

Maybe the article mentioned can provice further guidance?

Have a nice sunday,

   Wolfram


--2fw5crfd3oxs2lrd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEOZGx6rniZ1Gk92RdFA3kzBSgKbYFAlkhZGIACgkQFA3kzBSg
KbZaxxAAq037JXtlr1oyJ0SLOrU10B/pCgA7stFwfb2fiylVoO8+j8umqTHF3Jsm
F/eVKuPuRV9vjWmUsc11nxskPZUYc6L7lfLUSb+Cp4+RuToYJDmGX2+K9Csp7n5Z
dPzehlzJGI6sqZv+IblEJ0fp16GCPCOJkdwDVAuygUoXTIkuv/ZtI0QdaMOaHDxh
me5+X5+aipmERSgo6J0hdEinBv36XgZivjH1aFjkTNe19UOuKrHLQ+glfUAFi9uC
r89vxwh4FuFS0LQGDpWFPO+qz9lw59cH5WyxMIEPxqnMMp/KvQbHOmnpU85nkJsl
sxiFW8meWPwMLXSYqa1Fkv5xgun98BWE2ylmWoHnysan/nPbLWK8RorslyQvA/6g
ST/QrOzVdftZ9L5rBdtusaZ11RBNHcjs+eIZ8drkb2UNiJ6Qnkux1BPZRgwgwUVT
EyWsLZ0SPpVtSwOEGAQCHzv+nC7z9/wb+DcTH/hDhSNn4NCN5BIVTXo3EbI6xAoj
pgna5GIw9DrhcNIj31cYT8bFp2OwnpsBaEWoFwGJQaWY+yocxDXiD1kJMklWWvyZ
gujFvvylJd5xeNbp/aBB25LvXWQrkIaMAU779tLBRxgCf7i4Hek4DuP3oLNstkpT
d/0mt8e2AXK2hDD62cwGu+61QJ5tQ+yVZPTKljrEA0ZN5Q6LVaY=
=oajf
-----END PGP SIGNATURE-----

--2fw5crfd3oxs2lrd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
