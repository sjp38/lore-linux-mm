Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 504B76B0645
	for <linux-mm@kvack.org>; Thu, 10 May 2018 17:50:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d20-v6so1780500pfn.16
        for <linux-mm@kvack.org>; Thu, 10 May 2018 14:50:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d187-v6sor444870pgc.10.2018.05.10.14.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 14:49:58 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <AE0124C4-46F7-4051-BA24-AC2E3887E8A3@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_D589F850-881C-4AD8-A64A-59F465F470ED";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Date: Thu, 10 May 2018 15:49:53 -0600
In-Reply-To: <20180510064013.GA11422@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-2-hch@lst.de>
 <20180509151243.GA1313@bombadil.infradead.org>
 <20180510064013.GA11422@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org


--Apple-Mail=_D589F850-881C-4AD8-A64A-59F465F470ED
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On May 10, 2018, at 12:40 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> On Wed, May 09, 2018 at 08:12:43AM -0700, Matthew Wilcox wrote:
>> (page, len, off) is a bit weird to me.  Usually we do (page, off, len).
> 
> That's what I'd usually do, too.  But this odd convention is what
> bio_add_page uses, so I decided to stick to that instead of having two
> different conventions in one family of functions.

Would it make sense to change the bio_add_page() and bio_add_pc_page()
to use the more common convention instead of continuing the spread of
this non-standard calling convention?  This is doubly problematic since
"off" and "len" are both unsigned int values so it is easy to get them
mixed up, and just reordering the bio_add_page() arguments would not
generate any errors.

One option would be to rename this function bio_page_add() so there are
build errors or first add bio_page_add() and mark bio_add_page()
deprecated and allow some short time for transition?  There are about
50 uses under drivers/ and 50 uses under fs/.

Cheers, Andreas






--Apple-Mail=_D589F850-881C-4AD8-A64A-59F465F470ED
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlr0voIACgkQcqXauRfM
H+A1mg/+JbxLgylupOU2sRAmpQK8Frg1K/ZSUEJHtt0hueCF83YAD0AhxVXybB71
RJQ3I+Q4rU0ALUJMyJpQKSw29KJDMwEZ7H59Ao3YwriXSV5f19vG3S0gSj3ROzhL
ApoiD+Z6CP8m9W/bRFq8r/Oz0WnMOwO7TiIY40Kh7AqebtqUpGqY8rb+j0q/S5ci
lb9d0HZrwIP2Ba84iATeiZcVuXLk1Lk3EPNpzDcULZ9tmRNVoJJRHnY2pnWufkz2
a2D8/OizVsei9y9JesLkqfdQszlKBX/MQRpK9wiYgPleGkKZnDoL7uH+QXA2tZ19
BHU8WmSGN8yjkyaT2loY3NEOiwoZ9BW7SLqKxxKLhFjNHVyOr2Br1M70fzOU+VEC
kxY3flBuBjhEJoNobTwbAEXMZqwqJFm+2GAH937DefnHeaJ4pRmOOwx3dY/SvLf5
Z9o3qIEPWSbPik1x8T7ZNOXKxzDKqh/SzcJ6+bzcVZHP7E+lXxBgWiPdrmL8FMC2
TYruk2BM6XXbauXWb1pTegDVoxEhHK/XNWP4Ft5eZ2Rj3we89MB0I0p1XCxnV145
awy5o1lclkEowcNe8YXkw4VuBkaJPrIUPxEFIPAp7LHr295gUxvlr83aatIS7fjM
H5t0eMuTPZzmQ0xEzuVFS23c3KKM18pj5BEOT9c6957OJbU0TgU=
=gYo5
-----END PGP SIGNATURE-----

--Apple-Mail=_D589F850-881C-4AD8-A64A-59F465F470ED--
