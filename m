Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id F14FC6B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 10:57:13 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so32835337qkc.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:57:13 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id a89si618440qkj.127.2015.09.11.07.57.12
        for <linux-mm@kvack.org>;
        Fri, 11 Sep 2015 07:57:13 -0700 (PDT)
Date: Fri, 11 Sep 2015 10:57:12 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v2] mlock.2: mlock2.2: Add entry to for new mlock2 syscall
Message-ID: <20150911145712.GA3452@akamai.com>
References: <1441030820-2960-1-git-send-email-emunson@akamai.com>
 <55F14E05.6020304@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Content-Disposition: inline
In-Reply-To: <55F14E05.6020304@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mtk.manpages@gmail.com, Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 10 Sep 2015, Vlastimil Babka wrote:

> On 08/31/2015 04:20 PM, Eric B Munson wrote:
> > Update the mlock.2 man page with information on mlock2() and the new
> > mlockall() flag MCL_ONFAULT.
> >=20
> > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
>=20
> Looks like I acked v1 too late and not v2, so:
>=20
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>=20
> However, looks like it won't be in Linux 4.3 so that part is outdated.
> Also, what about glibc wrapper for mlock2()? Does it have to come before =
or
> after the manpage and who gets it in?

V3 now has an updated version, hopefully mlock2 hits the 4.4 merge
window.

I don't know about the glibc wrapper, are we expected to write one
ourselves?  Will they even take it?  They haven't been the most open
minded about taking wrappers for system calls that are unique to Linux
in the past.


--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV8uvIAAoJELbVsDOpoOa9RjcQAIODa85rnz8GGMBo8OUdyWnZ
Bv70lnehp42Sc2Jkvu66gsa5Zi252m42XI8/1DJ1MPiXHCoRJbhhlONL6P3nezbG
aAgG3ejDG/BIpyWK4sqIvbX09vqJgszX/l7MOCGxtBxQq9j/xBbTxwCN29w8bIel
lfCQIBoynwkwXfUi9HqCrQ/A/76Ca9gsL2hqzA1aqwF98ohWd4+P/RmM9E2X1WLL
leMxahn33BtX2uoNp6hYpEDBoaAS1vkSmVPD+BXNuXhStNn29XRDZzVDyZ72SmvY
3o3i9j/vMuNtt0sZKhhVklnNDaVIEc1y2bytzpUN924ofPZaRCTfObz+CEmeVeUv
jBoNUrw9IiraEGAq8XZetAOTktUyESBfVOwR8WR4qQ7NS3p/QtMsSdsUy21XQQvU
RBCdkc0NoX5+7MugZpz9xQBbXrTwjhVhIVaPssluf6CK/bBvgwjRvds+Wrrsxd6b
tyimo2T6G4fE0nhQaGzm+gsN26+B8T9c6BN4OKr0zmxy/LS9tm36k5N5mIsWqdMO
WnvJsfu2zm85cpMY5wo5MIBZIGCNE5qOeK1FV2iWE3THUHW2Zqm5moaEfDYS6gIy
AuQ8zXGScE7/gmg6RHlvRQqrD/mgfQIOLkTEpWGwXS9/6ePQsKHi8XS9wZwJyRfX
mYcAlGRxq1ovIIzXpZnQ
=mgxZ
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
