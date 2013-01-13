Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 61A2F6B0071
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 11:09:58 -0500 (EST)
Date: Sun, 13 Jan 2013 18:10:57 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: huge zero page vs FOLL_DUMP
Message-ID: <20130113161056.GA2046@otc-wbsnb-06>
References: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
 <20130112033659.GA26890@otc-wbsnb-06>
 <1358041388.31895.0.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <1358041388.31895.0.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 12, 2013 at 07:43:08PM -0600, Simon Jeons wrote:
> On Sat, 2013-01-12 at 05:36 +0200, Kirill A. Shutemov wrote:
> > On Fri, Jan 11, 2013 at 03:53:34PM -0800, Michel Lespinasse wrote:
> > > Hi,
> > >=20
> > > follow_page() has code to return ERR_PTR(-EFAULT) when it encounters
> > > the zero page and FOLL_DUMP flag is passed - this is used to avoid
> > > dumping the zero page to disk when doing core dumps, and also by
> > > munlock to avoid having potentially large number of threads trying to
> > > munlock the zero page at once, which we can't reclaim anyway.
> > >=20
> > > We don't have the corresponding logic when follow_page() encounters a
> > > huge zero page. I think we should, preferably before 3.8. However, I
> > > am slightly confused as to what to do for the munlock case, as the
> > > huge zero page actually does seem to be reclaimable. My guess is that
> > > we could still skip the munlocks, until the zero page is actually
> > > reclaimed at which point we should check if we can munlock it.
> > >=20
> > > Kirill, is this something you would have time to look into ?
> >=20
> > Nice catch! Thank you.
> >=20
> > I don't think we should do anything about mlock(). Huge zero page cannot
> > be mlocked -- it will not pass page->mapping check in
>=20
> Hi Kirill,
>=20
> What's store in page->mapping of huge zero page?

NULL.

--=20
 Kirill A. Shutemov

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ8tyQAAoJEAd+omnVudOMncQP/1hTBejcZ96ugWXfzAFC9O1v
Rq5ZTpnkYbmCBt+m6NGn6gw0mZDnUpH42EMVAy34RrL4BfOsClkXRB4CP0zaKP+i
G3QE10Mj37+mF+VnekZTjuAH7sbygst4Roi7ZzXiKBPuIYMFkSLdYfpkxdSmVQi0
4qOryAV87gXi74bNXr1rYSc/0VADEYaTKsryPXaadlJk/AX+WY29GKqUiCq6CgLG
Ey0/y4pK7UsUYgWVW7SoIHoHZwmMFmyiIwZywGTWYFydBA8klZAHG3GyNohEzUGZ
HDYE22/wYSeLtvp9AX5JDXB8QL3K/i3jEWTZdQ6SGdKM8DGy26hVZd4kJtT5UTt3
Ofpult4m9xLwYz3448iknJKa+wCz15Z/ZYrP/BOYy/emx1NkcBgQsBrN+UU0MBQM
8yTqDqZGut7hM3qn/ba3b1cL+KSzS1R+OJ+cKG2Ki3RwhTgm7PKbfCZ6dIHJSD/8
XQIGrcRVltUouExhedLYXnCHqrx2RM2zfXh9IKaiMyVnTRcRfVXyQ/MVMAC5ouaU
Hk+HQet5k0cBoESr7JhlMSxN3DmO9gftgnYlo0xootuogWXmASq/mkC0XqmGwvWg
BaT5Q+yVI88jrs8CabucOHWOGZetaIaq0GdQTDch+jJOdvrWeK+3NBhqWR+pakF4
I4tLJB+pIqjMzsVE2VtN
=gvF9
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
