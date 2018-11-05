Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6AFD6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:14:32 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so22612959qkf.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:14:32 -0800 (PST)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id r4-v6si1166333qkd.257.2018.11.05.08.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:14:32 -0800 (PST)
Received: from mr4.cc.vt.edu (mr4.cc.ipv6.vt.edu [IPv6:2607:b400:92:8300:0:7b:e2b1:6a29])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id wA5GEW6f022694
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:14:32 -0500
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by mr4.cc.vt.edu (8.14.7/8.14.7) with ESMTP id wA5GEQQ7005449
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:14:32 -0500
Received: by mail-qk1-f198.google.com with SMTP id c84so22515477qkb.13
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:14:31 -0800 (PST)
From: valdis.kletnieks@vt.edu
Subject: Re: Creating compressed backing_store as swapfile
In-Reply-To: <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com> <20181105155815.i654i5ctmfpqhggj@angband.pl>
 <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1541434463_4003P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 05 Nov 2018 11:14:23 -0500
Message-ID: <42594.1541434463@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Cc: Adam Borowski <kilobyte@angband.pl>, Pintu Agarwal <pintu.ping@gmail.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

--==_Exmh_1541434463_4003P
Content-Type: text/plain; charset=us-ascii

On Mon, 05 Nov 2018 11:07:12 -0500, "Austin S. Hemmelgarn" said:

> Performance isn't _too_ bad for the BTRFS case though (I've actually
> tested this before), just make sure you disable direct I/O mode on the
> loop device, otherwise you run the risk of data corruption.

Did you test that for random-access. or just sequential read/write?
(Also, see the note in my other mail regarding doing a random-access
write to the middle of the file...)


--==_Exmh_1541434463_4003P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBW+BsX40DS38y7CIcAQKKYwf+JIV/RuxK/7zIKKuu0D7pKRGkvTgaqGWD
zEMpdlcFYT3HXlXwL84EElJ4hiE3b1CZKfaDHqyYjLG+Q7WbY93n8Hmu9IFPH3F5
riIz1q62Ik8jfpjKFEoRGibbPutIgCL5y7WAXtdDnGy+1LB3ifHl3qu/Z3AlJzp1
zE8S5Du91C4qF+N0sPN9TyyKPu7+xGgGL3yYYpyRS58wMO6fxOLGwd82tNiv90mc
4wka1FtNq88S+l9WhREscHIctAt57pHStkDcChiFGmpf8Fb6WzATMUWO3JCo4mKr
Fd+zC9LB3/8hsaBxTYP88+MBp8qtj+2deUCW0U97pLs/Mz/rLaWK5w==
=yLe4
-----END PGP SIGNATURE-----

--==_Exmh_1541434463_4003P--
