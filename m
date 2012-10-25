Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 9880B6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 18:09:39 -0400 (EDT)
Date: Fri, 26 Oct 2012 01:10:31 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121025221031.GA29910@otc-wbsnb-06>
References: <20121023070018.GA18381@otc-wbsnb-06>
 <20121023155915.7d5ef9d1.akpm@linux-foundation.org>
 <20121023233801.GA21591@shutemov.name>
 <20121024122253.5ecea992.akpm@linux-foundation.org>
 <20121024194552.GA24460@otc-wbsnb-06>
 <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
 <20121025204959.GA27251@otc-wbsnb-06>
 <20121025140524.17083937.akpm@linux-foundation.org>
 <20121025212251.GA31749@shutemov.name>
 <20121025143707.b212d958.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yrj/dFKFPuw6o+aM"
Content-Disposition: inline
In-Reply-To: <20121025143707.b212d958.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 25, 2012 at 02:37:07PM -0700, Andrew Morton wrote:
> On Fri, 26 Oct 2012 00:22:51 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>=20
> > On Thu, Oct 25, 2012 at 02:05:24PM -0700, Andrew Morton wrote:
> > > hm.  It's odd that the kernel didn't try to shrink slabs in this case=
=2E=20
> > > Why didn't it??
> >=20
> > nr_to_scan =3D=3D 0 asks for the fast path. shrinker callback can shink=
, if
> > it thinks it's good idea.
>=20
> What nr_objects does your shrinker return in that case?

HPAGE_PMD_NR if hzp is freeable, otherwise 0.

> > > > I also tried another scenario: usemem -n16 100M -r 1000. It creates=
 real
> > > > memory pressure - no easy reclaimable memory. This time callback ca=
lled
> > > > with nr_to_scan > 0 and we freed hzp. Under pressure we fails to al=
locate
> > > > hzp and code goes to fallback path as it supposed to.
> > > >=20
> > > > Do I need to check any other scenario?
> > >=20
> > > I'm thinking that if we do hit problems in this area, we could avoid
> > > freeing the hugepage unless the scan_control.priority is high enough.=
=20
> > > That would involve adding a magic number or a tunable to set the
> > > threshold.
> >=20
> > What about ratelimit on alloc path to force fallback if we allocate
> > to often? Is it good idea?
>=20
> mmm...  ratelimit via walltime is always a bad idea.  We could
> ratelimit by "number of times the shrinker was called", and maybe that
> would work OK, unsure.
>=20
> It *is* appropriate to use sc->priority to be more reluctant to release
> expensive-to-reestablish objects.  But there is already actually a
> mechanism in the shrinker code to handle this: the shrink_control.seeks
> field.  That was originally added to provide an estimate of "how
> expensive will it be to recreate this object if we were to reclaim it".
> So perhaps we could generalise that a bit, and state that the zero
> hugepage is an expensive thing.

I've proposed DEFAULT_SEEKS * 4 already.

> I don't think the shrink_control.seeks facility had ever been used much,
> so it's possible that it is presently mistuned or not working very
> well.

Yeah, non-default .seeks is only in kvm mmu_shrinker and in few places in
staging/android/.

--=20
 Kirill A. Shutemov

--yrj/dFKFPuw6o+aM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQibjXAAoJEAd+omnVudOMNa8QAK7eUWJmXmCZKq3S7uliRiCn
bH8FzXujwhh5ZwGD4W/r3Chr0ryAT+MWAaoqF5I5m+rT7nDZsUy4cZ89REmpzXg2
J0brOR+B7sv+h/I8iXHqw5CYkCe2julL5ODamzDxkPzrR8CCTnJaWieKx/gRieEV
c3yuyttzJX7pzI8HZwyjnRZ4Q4bx/sfIU0BiqDIN+Q9puTSHCsv1jMEdB3G6Se3x
/gniemBNsVDHt5VCjizM8+Np2TVX4s+M5WX2CsJGQwBjH/ohjUBfpyt3wvOrNPhz
+X7oL0RA5y3Ytjre1g3c/yGmAS7tV0jXtGq941yiM8+hBqL6dyyFPLx8Z+foxFVN
8qniKapDLBQ/hzwbCYbBVXYfbL9yx3j8AwfVw7+ZXfXZAPdQT3n6sAH2CNqPnEDI
g15y4J9+RymXZhyWcln1Y9biM1VvrccR1ZjsQTQ+muJPOyTyCSeD6eDTgdt4POv5
bZz0MtpAP84MapwDu2nDptUzdYQ8ih2IYXN8RrJ2aBw2TKDUDBGhgY93X81M1F8t
5XQEtcQfbB77qh6FXyJVlobELwTndYLb/5skfuva/nMYoA5XVQ/+L04EKKTNkzx5
OSN9PFyt8qwNN46IG9Ylfv0UnYkmXXHvvm9GuE0oJrVCowEs8oaIevN0At6kdJf2
m7ylM3tNYu0VO6WDP9tt
=MU0Q
-----END PGP SIGNATURE-----

--yrj/dFKFPuw6o+aM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
