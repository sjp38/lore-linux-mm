Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56ADD6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:59:32 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id s189so9389737vkh.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:59:32 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id i4si5225435qtd.91.2016.07.27.11.59.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 11:59:31 -0700 (PDT)
Message-ID: <1469645861.10218.23.camel@surriel.com>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
From: Rik van Riel <riel@surriel.com>
Date: Wed, 27 Jul 2016 14:57:41 -0400
In-Reply-To: <20160727184445.GG21859@dhcp22.suse.cz>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	 <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	 <20160727163351.GC21859@dhcp22.suse.cz>
	 <1469643382.10218.20.camel@surriel.com>
	 <20160727184445.GG21859@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-L20y8eXVuCaKErK+/ore"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org


--=-L20y8eXVuCaKErK+/ore
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-27 at 20:44 +0200, Michal Hocko wrote:
> On Wed 27-07-16 14:16:22, Rik van Riel wrote:
> >=20
> > On Wed, 2016-07-27 at 18:33 +0200, Michal Hocko wrote:
> > >=20
> > > On Wed 27-07-16 10:47:59, Janani Ravichandran wrote:
> > > >=20
> > > >=20
> > > > Add tracepoints to the slowpath code to gather some
> > > > information.
> > > > The tracepoints can also be used to find out how much time was
> > > > spent in
> > > > the slowpath.
> > > I do not think this is a right thing to measure.
> > > __alloc_pages_slowpath
> > > is more a code organization thing. The fast path might perform an
> > > expensive operations like zone reclaim (if node_reclaim_mode > 0)
> > > so
> > > these trace point would miss it.
> > It doesn't look like it does. The fast path either
> > returns an allocated page to the caller, or calls
> > into the slow path.
> I must be missing something here but what prevents
> __alloc_pages_nodemask->get_page_from_freelist from doing
> zone_reclaim?

You are right!

Guess the script may need to collect all the
tracing output from __alloc_pages_nodemask on
up, and then filter the output so only the
interesting (read: long duration) traces get
dumped out to a file.

--=20
All rights reversed

--=-L20y8eXVuCaKErK+/ore
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXmQQmAAoJEM553pKExN6DlsEH/jDhmZz8jbCjaDvuE52Gr0DV
31gMd+1EwrLnBlo0AyxsdaiLtONjXs8ZJfybaaABMLnUclHPdqq/Zr5Ox7p3r3dR
K5OBmB7R+vUpjrYxzMVHvw1WaTYseGWNOOjNdQyo2uRGe2MXQ0jRRAJ+Og+EMMvd
4SNX1mNFNKyZRlVbAv/DdRS3VKVdTi85oVjcctIIDETd7utt5MKhRWX2FoF+l2Ia
NAJkqsQdsouNiLLHOdnnS1HqhUA0kx+6u1OVm47bd1PAu5qIYms3ocXeitic0e4o
Udc5EO9JrTQy4eJPxPr1ie2i4cVF61Dg4MyZrCQWyinTV4eBCbWeHbMyfaCPRM8=
=HeUd
-----END PGP SIGNATURE-----

--=-L20y8eXVuCaKErK+/ore--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
