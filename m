Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E93356B0069
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 19:03:08 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h65so67014902lfi.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:03:08 -0800 (PST)
Received: from smtp22.mail.ru (smtp22.mail.ru. [94.100.181.177])
        by mx.google.com with ESMTPS id a142si3297281lfa.52.2017.01.23.16.03.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 16:03:07 -0800 (PST)
Message-ID: <1485216185.5952.2.camel@list.ru>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
From: Alexandr <sss123next@list.ru>
Date: Tue, 24 Jan 2017 03:03:05 +0300
In-Reply-To: <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
References: <bug-192571-27@https.bugzilla.kernel.org/>
	 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
	 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
	 <20170118013948.GA580@jagdpanzerIV.localdomain>
	 <1484719121.25232.1.camel@list.ru>
	 <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512


> Why would you do this?A A There's no benefit of using zswap together
> with zram.

i just wanted to test zram and zswap, i still not dig to deep in it,
but what i wanted is to use zram swap (with zswap disabled), and if it
exceeded use real swap on block device with zswap enabled.
-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEl/sA7WQg6czXWI/dsEApXVthX7wFAliGmbkACgkQsEApXVth
X7zyDQ/9HMnJ5JzAAkrWJKlvpA+H6CRw0YBO77zQ44lr9R5jqmVAhU3XS6+dfYpA
ZL9lwG8zEqSDUCakko4vRVaeOiy3qzCNQcect2J1I9aGrHFIkC0I/ifPpbXRa4s5
+D45mSUzGxnMMz1XZrOkvuNsbzdWuTmQqTUqnJVovRD/V62u8Y50gDL3zkz/9x7L
mLjl/5WGjBAOQtwYpq1uE7FAJFHjV2cX8yI5JrFzMK1oghjFfqPFiYbD0yqSR2MB
QFdDQlqhMZ7Dwnk0P/WzIpJXdoT2NXH1iWRsvvKYeMwRP7hIzEnkpxfTlYtBK5xu
7zw/IEa0prLaEtYEh1j6h8Tzn6wKNeIT3t0g2yBT3QC8BW/v7AODlj95C+jIR06f
tikDCx+DUDuP96SW6RIjVLODCt/4yCzgVdxoAD5AbAyY+pU+JEmDkz8L60Gk2mC9
OG9IExiCCY/G3069A6UZROSFrrZGgrP75JGhTP91cS/XGH/HODFmqHQVVp45cED9
wn820IGjB2AAI6MmmRCvgqzUs99PTv8Xqr/x2Ea/ce+lFiU+L5x+xY7Q1q3KhQpQ
pLqLShi9iQUAzIYAtXZNPlbgwDtbYqz5sIAa6cmiv92bcRgJdPf4SiWLBUzIVi0M
KkNXiyo3XkDXoC8P1WjzLoexoJtOJooUbPcKimCI8Ef6+s5PmC0=
=Pyde
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
