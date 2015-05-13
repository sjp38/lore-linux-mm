Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E6B6D6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:48:31 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so53870315pdb.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:48:31 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id yf4si27339882pbc.185.2015.05.13.07.48.30
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 07:48:31 -0700 (PDT)
Date: Wed, 13 May 2015 10:48:30 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
Message-ID: <20150513144830.GF1227@akamai.com>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
 <20150513144506.GD1227@akamai.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dWYAkE0V1FpFQHQ3"
Content-Disposition: inline
In-Reply-To: <20150513144506.GD1227@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>


--dWYAkE0V1FpFQHQ3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 13 May 2015, Eric B Munson wrote:

> On Wed, 13 May 2015, Michal Hocko wrote:
>=20
> > From: Michal Hocko <mhocko@suse.cz>
> >=20
> > MAP_LOCKED had a subtly different semantic from mmap(2)+mlock(2) since
> > it has been introduced.
> > mlock(2) fails if the memory range cannot get populated to guarantee
> > that no future major faults will happen on the range. mmap(MAP_LOCKED) =
on
> > the other hand silently succeeds even if the range was populated only
> > partially.
> >=20
> > Fixing this subtle difference in the kernel is rather awkward because
> > the memory population happens after mm locks have been dropped and so
> > the cleanup before returning failure (munlock) could operate on somethi=
ng
> > else than the originally mapped area.
> >=20
> > E.g. speculative userspace page fault handler catching SEGV and doing
> > mmap(fault_addr, MAP_FIXED|MAP_LOCKED) might discard portion of a racing
> > mmap and lead to lost data. Although it is not clear whether such a
> > usage would be valid, mmap page doesn't explicitly describe requirements
> > for threaded applications so we cannot exclude this possibility.
> >=20
> > This patch makes the semantic of MAP_LOCKED explicit and suggest using
> > mmap + mlock as the only way to guarantee no later major page faults.
> >=20
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
>=20
> Does the problem still happend when MAP_POPULATE | MAP_LOCKED is used
> (AFAICT MAP_POPULATE will cause the mmap to fail if all the pages cannot
> be made present).
>=20
> Either way this is a good catch.
>=20
> Acked-by: Eric B Munson <emunson@akamai.com>
>=20
Sorry for the noise, this should have been a

Reviewed-by: Eric B Munson <emunson@akamai.com>


--dWYAkE0V1FpFQHQ3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVU2Q+AAoJELbVsDOpoOa9pw0QAJNQUeH65rfob8aNYHt8BEJX
5PJjFCHF0JkM8RR6CQUyFmZST5c/+G1oHY0DpoT5sWYFFoAFx0WziiIs1y3QC5tW
gQoZXTY/jvlm9z8F6pcZKEnMgMTNtkvhjcP4/4uYXfB6dCcBbv3NmuWqpGjCal2W
IiHZUwroFS14kIfcEr5WHfpuQAeSt4kEy2C8E/T92e3WZ9Gqks8x1T8OyVTQitxw
7N58hqndfG5tBTgHOIwsIfuxyvYvCnTg+gRWyoWsBaSbMOTDj/v9EWZCe7HDX78u
eVJWNrpqx53TdNzx2stk4pwwGtkFOlv9Twq82ezgm/ByYKfBpUPMJk1XyxOsUkwn
KOjmDMFIVaMCviCLBvqJL1B4gKK5zz10HkhndDj2LRr2LDQOcwhqNaBlvFOPnboZ
lqou163GbbiJxC7hm1uySQJW+slYvy0d2g+rYoZ9WFKWfBIyrQKb3O/VR4hyojkB
oqLcZpY9cFVP1nft7cjJEvKWYNIXrkrpOZ+VkkMcFSqeiGj0GQNCnCHIPQn+jwvP
lZpcYtvfqGqkmMM2fXZFFFQ5ZSeYiGL2bWocbQXn3+wdq1YqYvbsw7VtHLtSO7XB
c70vrUpnmfdvjS3mg5TsxapxyE07T0SQqMCjY07sfAodZbKy6IUQORza8ut+TV3S
csaAt+4Olc28v/8N79tC
=KLpL
-----END PGP SIGNATURE-----

--dWYAkE0V1FpFQHQ3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
