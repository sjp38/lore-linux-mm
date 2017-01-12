Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF7D36B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:47:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so61331882pfb.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:47:19 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r39si9763636pld.128.2017.01.12.08.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:47:18 -0800 (PST)
Date: Thu, 12 Jan 2017 08:47:18 -0800
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH v5 3/9] mm/swap: Split swap cache into 64MB trunks
Message-ID: <20170112164717.GA26499@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <735bab895e64c930581ffb0a05b661e01da82bc5.1484082593.git.tim.c.chen@linux.intel.com>
 <20170111150940.25d951a121a62e1b7eff6f8d@linux-foundation.org>
 <20170111231937.GH8388@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q68bSM7Ycu6FN28Q"
Content-Disposition: inline
In-Reply-To: <20170111231937.GH8388@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 11, 2017 at 03:19:37PM -0800, Andi Kleen wrote:
> > Switching from a single radix-tree to an array of radix-trees to reduce
> > contention seems a bit hacky.  That we can do this and have everything
> > continue to work tells me that we're simply using an inappropriate data
> > structure to hold this info.
>=20
> What would you use instead?

I agree that this approach is a bit hacky.  However, it is pretty
effective and simple.  If later on we come up with a better solution to
scale modfication of the radix tree, we can collapse the radix trees.

I think developing a scalable radix tree with write modifications will
take quite a while and is a non-trivial effort. With almost memory speed
SSDs coming on the market soon, I think having a workable solution now
and optimizing it for long term is reasonabale.

Tim


--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYd7MVAAoJEKJntYqi1rhJ37gP+gMpkfG7NapantPNemSYIdLh
b/h5HDj83mCZ5kZjygBKkYtSn+IbBbMWdMmtKRZlDBcKfrx+AS50Rbdw8MoJqGsv
i0p1NwNv9gdhETq3NdT3EVJA3Ot2oj8wDPf4hRvJNPuoz+2OeLZfN5rsJ7GHlFMz
0POIJZVE3Qxw95A4y4IHaf2il4kc/ATDBUA03eSCL/fw/EOPB9vgY19sdxOcVvGP
wpn0B3u/FS3OzFZ6G/nLKyof0dAYgHQ9wC6j1Nv4+mEZmlHBCa2gjYgMakSjKuXN
T+BV5fLOef7eDdQnUeKuvknxkTrSfoFo/004cgM3FHabN3O8GmZmUVqt1bdh0e1g
45hgOEZsJNdPXvA7Ap9JyIso9zGnPhvgJKdnBS6bHVLR2LCR8BiIlswxx783elM/
+lvB0Ije8zj4vOF5mfQXk/7Mi8UAAgrk9nEdDRDlPkgNfGursTF88dfhJpcsNngV
eMCfYJwPoCNLLEeTCnsR9U3s9Gws9JN1JpoH3A9hXUdNpJLK3WRqkJnSOk1D0tfK
jKosZiQC8y+aQ4iuzguLqmmjzereMLfBi5BXxpiek87r7bwKL5e/+dv/wGlaHeEu
pv1Tv5Q1+E+dbJ2z4ipNCxpxXitAFJr8ul4aFcUVrhoGoe2g84D2ykzB786+emS7
gPm4I7//CrNh8TXGqwfV
=FkNN
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
