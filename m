Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A64596B0073
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:56:57 -0400 (EDT)
Date: Fri, 26 Oct 2012 16:57:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/2] numa, mm: drop redundant check in
 do_huge_pmd_numa_page()
Message-ID: <20121026135750.GA16598@otc-wbsnb-06>
References: <1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1351256885.16863.62.camel@twins>
 <20121026134129.GA31306@otc-wbsnb-06>
 <1351258992.16863.77.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <1351258992.16863.77.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 26, 2012 at 03:43:12PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-10-26 at 16:41 +0300, Kirill A. Shutemov wrote:
> > On Fri, Oct 26, 2012 at 03:08:05PM +0200, Peter Zijlstra wrote:
> > > On Fri, 2012-10-26 at 15:54 +0300, Kirill A. Shutemov wrote:
> > > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > >=20
> > > > We check if the pmd entry is the same as on pmd_trans_huge() in
> > > > handle_mm_fault(). That's enough.
> > > >=20
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > >=20
> > > Ah indeed, Will mentioned something like this on IRC as well, I hadn't
> > > gotten around to looking at it -- now have, thanks!
> > >=20
> > > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > >=20
> > > That said, where in handle_mm_fault() do we wait for a split to
> > > complete? We have a pmd_trans_huge() && !pmd_trans_splitting(), so a
> > > fault on a currently splitting pmd will fall through.
> > >=20
> > > Is it the return from the fault on unlikely(pmd_trans_huge()) ?
> >=20
> > Yes, this code will catch it:
> >=20
> > 	/* if an huge pmd materialized from under us just retry later */
> > 	if (unlikely(pmd_trans_huge(*pmd)))
> > 		return 0;
> >=20
> > If the pmd is under splitting it's still a pmd_trans_huge().
>=20
> OK, so then we simply keep taking the same fault until the split is
> complete? Wouldn't it be better to wait for it instead of spin on
> faults?

IIUC, on next fault we will wait split the page in fallow_page().

--=20
 Kirill A. Shutemov

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQipbeAAoJEAd+omnVudOM0m4QAI8etAdhOJjWGxqm5fZdKiRU
ny/JXSV0cayKZTxh3sn4QURM/lPQHXS3es17zI255qwMUjcU1bb1ptujvXV5Ji2r
5RD+v31BF+Ii1KZQ+DjQauptY5aEx28vkZAlZfkKHBI+NMeTGKLwCMLcD61Q04tE
k/x6lPtyiNoOpAT56nKy2iFsSQv9p4IrdUSuz6LZx9zC6FEfm3uuW9LR9PCAlZ95
KZ7sSXM/v22cZpRlkrjNiq/Pn7HCRTQ+EJjG14SKePvrFMlnq1c/Tb12oA0TMMVC
1PLkOvbkYl6t97+tH7E6efWo5PpL+96BLGYvKNJql+WH8YG5ck53QxvXuI9rC3WK
eCPNTFrib6b4hu3S3PUL+a2IJ5YAdcRW69lq7tLTrfgE+ByNrW9DwUNcr6Fy6rC6
gWHT84lWztMlIC4tEiGyTvIH5J44k1nJdsFHNnO5zxprX39Xc62XPL/7K5KR93i8
LYH3KtzsEx6eM178d8CybE460ACE8euHQoP1FiblQfw0qn6UJUa5oI8eiXoWHNP7
NJbjKpqJAcXd8y0uUEoFvlK0bhf7xvC+mL6GzuJS6PHlKrn9fbRNSuxlgWW7d7I/
vz62DmuIWe4+lML6mLll7E7oKpEZjJf5HBUYZF6a3+uFfYcsO+z31pkmF3cmtX0C
IgQzFli+g7PCpr/Or2xy
=Z1v1
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
