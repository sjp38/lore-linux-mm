Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A734D6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 01:42:18 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x1so82188707lff.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 22:42:18 -0800 (PST)
Received: from smtp42.i.mail.ru (smtp42.i.mail.ru. [94.100.177.102])
        by mx.google.com with ESMTPS id f41si14032556lfi.422.2017.01.24.22.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 22:42:16 -0800 (PST)
Message-ID: <1485326535.26401.2.camel@list.ru>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
From: Alexandr <sss123next@list.ru>
Date: Wed, 25 Jan 2017 09:42:15 +0300
In-Reply-To: <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com>
References: <bug-192571-27@https.bugzilla.kernel.org/>
	 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
	 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
	 <20170118013948.GA580@jagdpanzerIV.localdomain>
	 <1484719121.25232.1.camel@list.ru>
	 <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
	 <1485216185.5952.2.camel@list.ru>
	 <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

D? D?N?, 24/01/2017 D2 15:16 -0500, Dan Streetman D?D,N?DuN?:
> On Mon, Jan 23, 2017 at 7:03 PM, Alexandr <sss123next@list.ru> wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA512
> > 
> > 
> > > Why would you do this?A A There's no benefit of using zswap
> > > together
> > > with zram.
> > 
> > i just wanted to test zram and zswap, i still not dig to deep in
> > it,
> > but what i wanted is to use zram swap (with zswap disabled), and if
> > it
> > exceeded use real swap on block device with zswap enabled.
> 
> I don't believe that's possible, you can't enable zswap for only
> specific swap devices; and anyway, if you fill up zram, you won't
> really have any memory left for zswap to use will you?
> 
> However, it shouldn't encounter any BUG(), like you saw.A A If it's
> reproducable for you, can you give details on how to reproduce it?
it happened only once, and i am noticed it only because few
applications hang, but i can run this setup for a while,  and let know
if it happen again, it happened on io and memory intensive app, this
machine have heavy load sometime, so i think it may happen again.
-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEl/sA7WQg6czXWI/dsEApXVthX7wFAliISMcACgkQsEApXVth
X7zgMA/+KoI1rdpCfJdxrihlkKavJcfYR/EoI4FGzQadJb6mZSihzuHcLVcIhiLV
VH+9HNADgygur//EQMAsliqT7HNxdEIpouMU/4w9dDxWiUFaAFo6kQYztVSQog8X
Kd3zJ1YagxSOXv0yx/OiR40/NwXygLSW8zRQ0rVwOIO6TF05lJYUA5QQ6F+izHGB
syNDQUwOukQ8Bcaxctic+uE/nn55ufkHMyjCtlQG2jG6/gk1590fzxugsk69U0Ou
qq8zFyShhYQ2onw36cJWi62rXpKvj7mj/suo7FwwmmLBS2R9jcrQILTnYnhAM+YH
JkVsIjXJrIWGLd3jeFpHwJMmvuMe5jPT3ppGGx3m4QbdRe+DAujT+5bWaQC5ubnN
4H84h6kGEsNTelf2rfZs58MomQy61adgSwKqMpOw81b/H11fYuZTVmlqBkyFKzos
0fkSTdkpHXSoKkLw6sgr2ch+jLJanR29+T9VRuR2m4+PRdLrUZF3L5HBejYDkE5O
3eF+eR/cVXoyZleVUAJaG7KAM+P8KEvz5kZAOOTGixFM23L1KnIRejYcjpYgKGkG
Q4k5+w56ONkzmL6IKqx5eOHstCxSl1R/uKNNN9rwrq1sRuRUpcQlxFfneVS7U9eo
pKYcoyO/yiYKdXTH82d/LJBf6yISZcwMsBSPciSWXQuLPtvkeNE=
=PnJw
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
