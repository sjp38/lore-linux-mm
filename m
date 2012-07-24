Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 876E06B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 10:07:25 -0400 (EDT)
Date: Tue, 24 Jul 2012 17:09:11 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, RFC 0/6] Avoid cache trashing on clearing huge/gigantic
 page
Message-ID: <20120724140911.GA8270@otc-wbsnb-06>
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120723163020.5250e09e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
In-Reply-To: <20120723163020.5250e09e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 23, 2012 at 04:30:20PM -0700, Andrew Morton wrote:
> On Fri, 20 Jul 2012 15:50:16 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > Clearing a 2MB huge page will typically blow away several levels of CPU
> > caches.  To avoid this only cache clear the 4K area around the fault
> > address and use a cache avoiding clears for the rest of the 2MB area.
> >=20
> > It would be nice to test the patchset with more workloads. Especially if
> > you see performance regression with THP.
> >=20
> > Any feedback is appreciated.
>=20
> This all looks pretty sane to me.  Some detail-poking from the x86 guys
> would be nice.
>=20
> What do other architectures need to do?  Simply implement
> clear_page_nocache()?

And define ARCH_HAS_USER_NOCACHE to 1.

> I believe that powerpc is one, not sure about
> others.  Please update the changelogs to let arch maintainers know
> what they should do and cc those people on future versions?

Okay.

--=20
 Kirill A. Shutemov

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQDqyHAAoJEAd+omnVudOMLwkP/02InE8fF6zCcmRgu5I38Bn/
/K+IZp7KCxy0ppv32lc8hc+wViesMFk8DcoqXnEsO44dDxqC3Krytx3KOqJD2sPj
ssziLMclnpU2YcWBJQ4+fSZLWyLLjzH2h4boyN81IaG7tdvZ+Hksujys1WG3GPdU
f6xuEhSqrgJaANtuhZUaVR9xrgS1IxJNPsB/MhyteAuKW1GUDLRVqMWHGd2yq+/0
JArU5d532pPUsk0T+mYS7lbj25m0WBF5GfU8F11QmhbSjGUEyiQ5V5LPkszT+L9G
6K8CgFkIO2q2uoTmxGoc8zXCLJaGtUTazMXQKohExpgAzcJAA0OsYMz693Z9uFkX
Ap9nHAOmxAiPfqC2YWZlTmW+SHsAyLjh1XNqGRJAICykDm64xk1W0fKcl+uv3MRX
MLVB/SVkAlK/ub+LtUR40xz6PeYd2I6FY1dmqfFX/G+quFe1K/ONXx8tjrIYUrke
8ENLFL3NHBGB0aBCu731dShuzKkpi4lPo0WYstiI4cJOV+kDdM0E93e4aSMdkJjb
vPDbaEcypWFCzKr5/kJZSO3AjLa9VfsXgnOdgsygySftJxOAdGG7oJbyGb0JVaI4
SjLN2lTAbJvaWYivQl44vFd7S49c0jbmPKkvMPU/qrqtBNkssfOB1ZlOA4vp05Ki
eEeGiq728CjRIkLdXrrb
=bkw/
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
