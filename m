Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id CB9DF6B0044
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:32:37 -0400 (EDT)
Date: Wed, 24 Oct 2012 23:33:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121024203329.GA24716@otc-wbsnb-06>
References: <20121018164502.b32791e7.akpm@linux-foundation.org>
 <20121018235941.GA32397@shutemov.name>
 <20121023063532.GA15870@shutemov.name>
 <20121022234349.27f33f62.akpm@linux-foundation.org>
 <20121023070018.GA18381@otc-wbsnb-06>
 <20121023155915.7d5ef9d1.akpm@linux-foundation.org>
 <20121023233801.GA21591@shutemov.name>
 <20121024122253.5ecea992.akpm@linux-foundation.org>
 <20121024194552.GA24460@otc-wbsnb-06>
 <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Content-Disposition: inline
In-Reply-To: <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 24, 2012 at 01:25:52PM -0700, Andrew Morton wrote:
> On Wed, 24 Oct 2012 22:45:52 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > On Wed, Oct 24, 2012 at 12:22:53PM -0700, Andrew Morton wrote:
> > >=20
> > > I'm thinking that such a workload would be the above dd in parallel
> > > with a small app which touches the huge page and then exits, then gets
> > > executed again.  That "small app" sounds realistic to me.  Obviously
> > > one could exercise the zero page's refcount at higher frequency with a
> > > tight map/touch/unmap loop, but that sounds less realistic.  It's wor=
th
> > > trying that exercise as well though.
> > >=20
> > > Or do something else.  But we should try to probe this code's
> > > worst-case behaviour, get an understanding of its effects and then
> > > decide whether any such workload is realisic enough to worry about.
> >=20
> > Okay, I'll try few memory pressure scenarios.
>=20
> Thanks.
>=20
> > Meanwhile, could you take patches 01-09? Patch 09 implements simpler
> > allocation scheme. It would be nice to get all other code tested.
> > Or do you see any other blocker?
>=20
> I think I would take them all, to get them tested while we're still
> poking at the code.  It's a matter of getting my lazy ass onto reviewing
> the patches.
>=20
> The patches have a disturbing lack of reviewed-by's, acked-by's and
> tested-by's on them.  Have any other of the MM lazy asses actually
> spent some time with them yet?

Andrea Revieved-by previous version of the patchset, but I've dropped the
tag after rebase to v3.7-rc1 due not-so-trivial conflicts. Patches 2, 3,
4, 7, 10 had conflicts. Mostly due new MMU notifiers interface.

I mentioned that in cover letter.

--=20
 Kirill A. Shutemov

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQiFCYAAoJEAd+omnVudOMw3sQAIcyQEn6ijiGBZvfOr2Ui6k1
1eOdG61OmPjla2g4NZLmArK+8LAxZq0SQxmfl9TTOXhbBaJxp8tsFNuhvk/OgC1m
BqOlQWmQ0lsKxgzSsO9azbeCWIdB85VopeEZtUzdFQqXiuknbL0Lofy+zrouRYJg
rd+jNsgtNOU5yqQg4u+dj6UtQNH/kVFlOlAIOPHwKNOnIkgd7QpPk4nCGx7w0YEI
ycYwhc9p+DPuSAst27udp+s2uQD5xhiMSDORrJbYZ3lpn5sZjpMrAXoZuqWHrCif
+iEJHe/V4DxEeAOXxpSsrwaflDqlNaOKlv0oN5Qp6ryps+BGUQi08ijFF6dHzf5b
2XyV2/Ln8+DH3xAXV3N7no9x63rSvZwqZDn/TjL+wLbFZRhGq2ITzuTk5gWbljBY
zX+9k5ZYo2HOOg/1A9lyVaYnxTUWzMdeEwsGBebaDcThDVEk/yDsT54ZX7mnbqNv
4WqBNIeDJ9CwkW39uQ6/HtgQcAaKZuCYSG871vSfVmVFhM2c8Kp6NC2IXcWFJRg8
g5jvSfr32fZbbgbd1+x9Anl3XwF+hdITPZjewn/Vk7czoTfL4a2rrNr5CtQlG63+
laxGBtzilCuqs9+cRGEaa6Ar8nNIp3HAMTrTqO7uLjOp5yMO9uWQolKIY33TjG3n
ZRH8ur3YvPAu4UICPDcK
=lpHO
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
