Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 060DF6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:54:06 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s70so22798843qks.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:54:06 -0800 (PST)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id v17si6609259qkf.62.2018.11.05.08.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:54:05 -0800 (PST)
Received: from mr4.cc.vt.edu (mr4.cc.ipv6.vt.edu [IPv6:2607:b400:92:8300:0:7b:e2b1:6a29])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id wA5Gs4Mb009707
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:54:04 -0500
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by mr4.cc.vt.edu (8.14.7/8.14.7) with ESMTP id wA5GrxwF015393
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:54:04 -0500
Received: by mail-qk1-f199.google.com with SMTP id 92so22664946qkx.19
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:54:04 -0800 (PST)
From: valdis.kletnieks@vt.edu
Subject: Re: Creating compressed backing_store as swapfile
In-Reply-To: <6a1f57b6-503c-48a2-689b-3c321cd6d29f@gmail.com>
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com> <20181105155815.i654i5ctmfpqhggj@angband.pl> <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com> <42594.1541434463@turing-police.cc.vt.edu>
 <6a1f57b6-503c-48a2-689b-3c321cd6d29f@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1541436836_4003P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 05 Nov 2018 11:53:56 -0500
Message-ID: <83467.1541436836@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Cc: Adam Borowski <kilobyte@angband.pl>, Pintu Agarwal <pintu.ping@gmail.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

--==_Exmh_1541436836_4003P
Content-Type: text/plain; charset=us-ascii

On Mon, 05 Nov 2018 11:28:49 -0500, "Austin S. Hemmelgarn" said:

> Also, it's probably worth noting that BTRFS doesn't need to decompress
> the entire file to read or write blocks in the middle, it splits the
> file into 128k blocks and compresses each of those independent of the
> others, so it can just decompress the 128k block that holds the actual
> block that's needed.

Presumably it does something sane with block allocation for the now-compressed
128K that's presumably much smaller.  Also, that limits the damage from writing to
the middle of a compression unit....

That *does* however increase the memory requirement - you can OOM or
deadlock if your read/write from the swap needs an additional 128K for the
compression buffer at an inconvenient time...


--==_Exmh_1541436836_4003P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBW+B1pI0DS38y7CIcAQIaSwgAlaWBTJLuKtJT7ru/WLIqVahEPpFO8vgl
0Wd9hwwQSj1a4HtpAkeRTo3/24JBDnIg315A8Q+YW0/zF9MP2cecGTCDT4tmJUR1
NhN2hoAnKvLleU5ZebPygptkEkiQdbs7G92ok/Zi32lPUwWVt1ZdQG3HVYHWtNxJ
ret95nyOWAgBJFJmb+I9kiO8O3RewbnfPjLRiUA1d1iaaK6Zilur44fG6K5KN5Yv
jxN/ee4UM+w/u3cTEpVyAdFqAVq8phDKn1Pa53LSa6TtHXoUOI3ir/k2owUxfzE6
pO+Len2d4Y2U1VcrfyB5yaLyd5gFGoe82qwsgregzqCbaygKQ4UgPg==
=OHwC
-----END PGP SIGNATURE-----

--==_Exmh_1541436836_4003P--
