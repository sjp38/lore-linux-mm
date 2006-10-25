Date: Wed, 25 Oct 2006 08:27:50 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
In-Reply-To: <20061025055223.GA2330@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0610250826320.8576@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com> <453EF4C1.5050102@kolumbus.fi>
 <20061025055223.GA2330@localhost.localdomain>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-579147584-1161761270=:8576"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>, Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-579147584-1161761270=:8576
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 25 Oct 2006, David Gibson wrote:
> On Wed, Oct 25, 2006 at 08:23:13AM +0300, Mika Penttil=C3=A4 wrote:
> > Shouldn't it be something like following ?
> >=20
> > size =3D (i_size_read(mapping->host) + HPAGE_SIZE - 1) >> HPAGE_SHIFT;
> >=20
> > If so this was wrong in the original code also.
>=20
> In theory, yes, but AFAIK there is no way to get an i_size on a
> hugetlbfs file which is not a multiple of HPAGE_SIZE.

Exactly.

Hugh
--8323584-579147584-1161761270=:8576--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
