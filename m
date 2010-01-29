Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8BD6B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 17:02:18 -0500 (EST)
From: Michail Bachmann <mb@emeraldcity.de>
Subject: Re: PROBLEM: kernel BUG at mm/page_alloc.c:775
Date: Fri, 29 Jan 2010 23:01:57 +0100
References: <201001092232.21841.mb@emeraldcity.de> <20100118120315.GD7499@csn.ul.ie> <201001210110.18569.mb@emeraldcity.de>
In-Reply-To: <201001210110.18569.mb@emeraldcity.de>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7036799.4qDCbclDcj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201001292302.04105.mb@emeraldcity.de>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--nextPart7036799.4qDCbclDcj
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> > On Tue, Jan 12, 2010 at 03:25:23PM -0600, Christoph Lameter wrote:
> > > On Sat, 9 Jan 2010, Michail Bachmann wrote:
> > > > [   48.505381] kernel BUG at mm/page_alloc.c:775!
> > >
> > > Somehow nodes got mixed up or the lookup tables for pages / zones are
> > > not giving the right node numbers.
> >
> > Agreed. On this type of machine, I'm not sure how that could happen
> > short of struct page information being corrupted. The range should
> > always be aligned to a pageblock boundary and I cannot see how that
> > would cross a zone boundary on this machine.
> >
> > Does this machine pass memtest?
>=20
> I ran one pass with memtest86 without errors before posting this bug, but=
 I
> can let it run "all tests" for a while just to be sure it is not caused by
> broken hw.

Please disregard this bug report. After running memtest for more than 10 ho=
urs=20
it found a memory error. The funny thing is, linux found it much faster...

Thanks for your time.

CU Micha

--nextPart7036799.4qDCbclDcj
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCAAGBQJLY1rWAAoJEDOFMLjtzdvOJrgP/A6Hpalr96+T5A5IaZRA2SPd
gp5s6ZSPnTD6gN7YC/yDJsONZ4dZRU6eEQFoH2CK2Bp7aXFzdOFiA0QNsHUZNE5z
LZiTdcCCCU56kxTUVR1LyLBPYaHwoKPo5rsJQLDlrX1eDXxtKHlXu6M6yX1DcptG
HYnbT665Jhr0/gDMP1lwzZHMTyRKuk+tdapfqU+dNxft466VVmERewhtn5WnaKoR
YxAUfTn+G3Im7ccetSzSm3GQybicU1isQpCbUQH9mVxXyvJ1usLeV0c6FeUcRsKU
wiiWKx3IrebpYNS0KshgO16/z2QKNtsgLHQVBw9UKUIKTf8/KaiH/5A3KW24H6Pj
7fMO/D1PDxkvw2UNyeu7JDgY6l8XkWoqngszJC+JtJPupTWyErDpoJ6euxHk/s67
Fx5t/6Z38n5UTzHhOqh+0+oyjTmhmlrLhi5XkJqYPcpzIv0Vo7mapmt5jSmNgA8X
hOfTiYUMNDrbZlPgHHtJDHR2VeqsvfY6JLzUULB7Ctr4IW+IiSg+0miCldJTpE1h
wxq2LeelB9EI3L0rgdsJAx+tHK6E8JsosHmfkSsvJEqCWHqS3/saKOp7Z7VHrUJZ
IutnobNri2Qyt6cqHjg5J+OzBldKUR9sJfUEOLtd5IND5INAtd/XzN6/KbQcBlts
1/OMirLEr0zIIccxdD5p
=OA0D
-----END PGP SIGNATURE-----

--nextPart7036799.4qDCbclDcj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
