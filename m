Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2505E6B000C
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 19:34:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y13-v6so1339403pgv.10
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 16:34:48 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x2-v6si5968143plr.223.2018.06.21.16.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Jun 2018 16:34:47 -0700 (PDT)
Date: Fri, 22 Jun 2018 09:34:21 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Message-ID: <20180622093421.6b060710@canb.auug.org.au>
In-Reply-To: <20180621180638.ahxpgzwrztopve55@pburton-laptop>
References: <20180606194144.16990-1-malat@debian.org>
	<CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
	<20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
	<20180621180638.ahxpgzwrztopve55@pburton-laptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/WC=h_N3UJqTfkjWbdcO478n"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@mips.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@gmail.com>, Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--Sig_/WC=h_N3UJqTfkjWbdcO478n
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Thu, 21 Jun 2018 11:06:38 -0700 Paul Burton <paul.burton@mips.com> wrote:
>
> I was expecting to see the original commit, then the revert, then
> perhaps a re-application of it but instead it looks like the commits
> from master are missing entirely after 25cf23d7a957 ("mm/memblock: print
> memblock_remove"). Maybe I'm missing something about the way the merges
> for linux-next are done..?

Andrew produces his mmotm quilt series and exports it to ozlabs.org
from where I fetch it and create the akpm-current and akpm branches in
linux-next (and merge them, obviously :-)).  The mmotm quilt series has
not changed since Jun 15, I assume Andrew is still finalising it.

> In any case, could we get the problematic patch removed from linux-next?

I have removed it from my copy of mmotm for today.

--=20
Cheers,
Stephen Rothwell

--Sig_/WC=h_N3UJqTfkjWbdcO478n
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlssNf0ACgkQAVBC80lX
0GwqnQgAlpelxvvi6Yhl4qtdIeKBlovkV5kAuzpaae6QMIv0SQi/aiu8PhM8HfRY
pZrhXMQl281ZpfKW9pfECeyFbBSXMLrQmlBw2rtFHbIJy25t+AdrToPPDSIiqnWJ
JJ6kPJxLzaJ8j4NGL1qdbOh5R3Ast4z1+SxspWAa80aXbZxAokbtuBln5pcLvKWG
RpigTqwdlugHIPWYhRixQC3jqc1YbDt3uNq/pvimTNo5y5Aks57oA2dkCLPKTAfi
qXhx+67AvvUenF6ajZ51pM8f4agmksmAUg3e2dL0J3xvsLjTJbl/5BQKHj32LZpo
VD9hM1JFqNvAja/EiAJ3xwD2E2V4KQ==
=NXVc
-----END PGP SIGNATURE-----

--Sig_/WC=h_N3UJqTfkjWbdcO478n--
