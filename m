Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C61BD6B009A
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 10:58:59 -0500 (EST)
Subject: Re: boot warnings due to swap: make each swap partition have one address_space
In-Reply-To: Your message of "Sun, 27 Jan 2013 13:40:40 -0800."
             <alpine.LNX.2.00.1301271321500.16981@eggly.anvils>
From: Valdis.Kletnieks@vt.edu
References: <5101FFF5.6030503@oracle.com> <20130125042512.GA32017@kernel.org> <alpine.LNX.2.00.1301261754530.7300@eggly.anvils> <20130127141253.GA27019@kernel.org>
            <alpine.LNX.2.00.1301271321500.16981@eggly.anvils>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1359474972_2191P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Jan 2013 10:56:12 -0500
Message-ID: <10359.1359474972@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1359474972_2191P
Content-Type: text/plain; charset=us-ascii

On Sun, 27 Jan 2013 13:40:40 -0800, Hugh Dickins said:

> My reservations so far would be: how many installations actually have
> more than one swap area, so is it a good tradeoff to add more overhead
> to help those at the (slight) expense of everyone else?  The increasingly
> ugly page_mapping() worries me, and the static array of swapper_spaces
> annoys me a little.

Right now, probably few.  But the number may go up a lot if the whole
'zram-for-swapspace' thing catches on and/or ships in a distro...

--==_Exmh_1359474972_2191P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUQfxHAdmEQWDXROgAQIxbw/+N1MQpUPq+NXQQZTBK1tTvYXz4zDp5GCe
yZ6kUMCOI/z/gAJhU9F8cyUQytu2LOk6cCbMOvceIulVBMVUdvVzWxz9UmIS/fXC
85qbulgXIGiCh5hOemqq5LhRzlOws9uX/0HOIUZVQOKBGa8gWSs+qHXwwwtpcDm0
VGLjqmY3dSGp0KWt46FPCm0ddg60uIQfEANFr/fyZTuxE2HoZHs5oADLI0c9nx9Q
pEcEBypJPSoqXrPToQhO+y23+y4Dwo75z4iw91d9FyUt6+SQ2Ki4c6UU+z9mvUEB
QHvlRXnq9jQvFOfy02ivYJW5EiUxH7L0D36LMDCQ4lCMyCfBTdOF2Sfr+pyV0hop
Z/cVe0IgXph1K1QsKA6X74NUWbrg77EvN9QAdxjHCOKXTymqhpJR+p3pMl/3D1fa
toi7sBYqXsVt+8ydpt0LsszIJTZvOLaTFf5FwkN76+U4DWbeJUIV9yaTwsiGdO1d
/ZgEn1U3GExA/UjDiNGmgUEOI65Bgx1nm2qgf7TVFL77BJQyN/2M3MJzcE2tAwbW
zija8wt7/81mUAxxTNSN6WsjFnEQ0FvUJ6+Gn3i6ThuDEJyGebxucxql/Vp6DvCH
RXdDSoUypaUGCy0Km+VtF5t2317Bofi99+Kq8RKLcCHse9z1pjHzrKjAlDkW3ExH
FPc5J5cI9OI=
=Ll4n
-----END PGP SIGNATURE-----

--==_Exmh_1359474972_2191P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
