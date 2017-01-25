Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D31A36B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:44:32 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l7so188113715qtd.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:44:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l198si10256506qke.24.2017.01.25.09.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 09:44:32 -0800 (PST)
Message-ID: <1485366269.29861.0.camel@redhat.com>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
From: Rik van Riel <riel@redhat.com>
Date: Wed, 25 Jan 2017 12:44:29 -0500
In-Reply-To: <20170125165522.GA11569@linux.vnet.ibm.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
	 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
	 <20170124132849.73135e8c6e9572be00dbbe79@linux-foundation.org>
	 <20170124222217.GB19920@node.shutemov.name>
	 <20170125165522.GA11569@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-nf7sxNz0ss/8KVmzHIUD"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>


--=-nf7sxNz0ss/8KVmzHIUD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-25 at 08:55 -0800, Srikar Dronamraju wrote:
> >=20
> > >=20
> > >=20
> > > >=20
> > > > For THPs page_check_address() always fails. It's better to
> > > > split them
> > > > first before trying to replace.
> > > So what does this mean.=C2=A0=C2=A0uprobes simply fails to work when =
trying
> > > to
> > > place a probe into a THP memory region?
> > Looks like we can end up with endless retry loop in
> > uprobe_write_opcode().
> >=20
> > >=20
> > > How come nobody noticed (and reported) this when using the
> > > feature?
> > I guess it's not often used for anon memory.
> >=20
> The first time the breakpoint is hit on a page, it replaces the text
> page with anon page.=C2=A0=C2=A0Now lets assume we insert breakpoints in =
all
> the
> pages in a range. Here each page is individually replaced by a non
> THP
> anonpage. (since we dont have bulk breakpoint insertion support,
> breakpoint insertion happens one at a time). Now the only interesting
> case may be when each of these replaced pages happen to be physically
> contiguous so that THP kicks in to replace all of these pages with
> one
> THP page. Can happen in practice?
>=20
> Are there any other cases that I have missed?

A JIT compiler placing executable code in anonymous
memory before executing it, and a debugger trying to
insert a uprobe in one of those areas?

Not common, but I suppose it could be done.

--=20
All rights reversed

--=-nf7sxNz0ss/8KVmzHIUD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYiOP9AAoJEM553pKExN6Dh9IH/j1lFxNybTM4bDL0C5IxF5LU
9R11ofS0yoPTP/JHeTXcUuU/Z2mQrHp0yKnaB7IIhIZZrU5zTpyn3bmazpGrS+yT
q0h+x0wk7qIS+zT0TH0xyepHcLghCY6PAvsJuQbf1R2ojgnnYCCvYgw1IptAEgyR
3R1VONEZMHL1gm82xkCvMwEOOkA1k4t9AJIDgP7USiDDugnB31cZTgbYpsb6rDiT
MTDs003hMteBFDDuYwmgGm6sou45DRv6ARN8+Fepw3fQi8V9iZQlb992sN9DQIDT
T7CeImAL8fb5YKl9E8U9b7y1vW9B58FdgLka2zKwkrKv0d7srbHTqvsg42F9asQ=
=wovX
-----END PGP SIGNATURE-----

--=-nf7sxNz0ss/8KVmzHIUD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
