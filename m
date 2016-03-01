Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 65E226B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 17:33:05 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id y89so155081935qge.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 14:33:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g68si33100262qgf.66.2016.03.01.14.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 14:33:04 -0800 (PST)
Message-ID: <1456871581.25322.62.camel@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
From: Rik van Riel <riel@redhat.com>
Date: Tue, 01 Mar 2016 17:33:01 -0500
In-Reply-To: <20160301214403.GJ3730@linux.intel.com>
References: <20160301070911.GD3730@linux.intel.com>
	 <20160301102541.GD27666@quack.suse.cz>
	 <20160301214403.GJ3730@linux.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Ae13PohY+/zwdyqA6RmI"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org


--=-Ae13PohY+/zwdyqA6RmI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 16:44 -0500, Matthew Wilcox wrote:
> On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
> > On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
> > > There are a few issues around 1GB THP support that I've come up
> > > against
> > > while working on DAX support that I think may be interesting to
> > > discuss
> > > in person.
> > >=20
> > > =C2=A0- Do we want to add support for 1GB THP for anonymous
> > > pages?=C2=A0=C2=A0DAX support
> > > =C2=A0=C2=A0=C2=A0is driving the initial 1GB THP support, but would a=
nonymous
> > > VMAs also
> > > =C2=A0=C2=A0=C2=A0benefit from 1GB support?=C2=A0=C2=A0I'm not volunt=
eering to do this
> > > work, but
> > > =C2=A0=C2=A0=C2=A0it might make an interesting conversation if we can=
 identify
> > > some users
> > > =C2=A0=C2=A0=C2=A0who think performance would be better if they had 1=
GB THP
> > > support.
> >=20
> > Some time ago I was thinking about 1GB THP and I was wondering:
> > What is the
> > motivation for 1GB pages for persistent memory? Is it the savings
> > in memory
> > used for page tables? Or is it about the cost of fault?
>=20
> I think it's both.=C2=A0=C2=A0I heard from one customer who calculated th=
at
> with
> a 6TB server, mapping every page into a process would take ~24MB of
> page tables.=C2=A0=C2=A0Multiply that by the 50,000 processes they expect=
 to
> run
> on a server of that size consumes 1.2TB of DRAM.=C2=A0=C2=A0Using 1GB pag=
es
> reduces
> that by a factor of 512, down to 2GB.

Given the amounts of memory in systems, and the fact
that 1TB (or even 2MB) page sizes will not always be
possible, even with DAX on persistent memory, I
suspect it may be time to implement the reclaiming of
page tables that only map file pages.

--=20
All Rights Reversed.


--=-Ae13PohY+/zwdyqA6RmI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJW1hidAAoJEM553pKExN6DwwsIAKHMsF676rXdpgEqK+U7tNWW
j5E5AvAWawWNCCSO7jiFUpH1GiD5NtHdulObsH1XiWY5OcxzBTeinNpRNWSCVDUW
RlA0GHh9CHrny5a/ZbupEyJwkOHRQSxB1J6ZlfnuiQkxjeWuf+gy7w8wlbUAnNsB
rprfi6C6WyPS5sSI93E68StLv6m9kJJfTPpF+KrwhPzq2NzmzzCfpULCcHNbDrU7
phgcw8zO3I/IcSDZ9ANp8ah+h8fXfdvTuekTAFO4IV+ImXFntS8ZfunTnuRJOmHG
lrpekXM3Iz2xd0Xq4mQ5SdP4cT7kpcrVnQbXdsTSHFwAcsJSMntQG/RIJKlTenM=
=qwst
-----END PGP SIGNATURE-----

--=-Ae13PohY+/zwdyqA6RmI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
