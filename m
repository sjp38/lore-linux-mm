Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6606B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 12:19:19 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id c6so29099269qga.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:19:19 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id u128si14188689qhb.120.2016.04.26.09.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 09:19:18 -0700 (PDT)
Subject: Confusing olddefault prompt for Z3FOLD
From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461686910_3054P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2016 12:08:30 -0400
Message-ID: <9459.1461686910@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1461686910_3054P
Content-Type: text/plain; charset=us-ascii

Saw this duplicate prompt text in today's linux-next in a 'make oldconfig':

Low density storage for compressed pages (ZBUD) [Y/n/m/?] y
Low density storage for compressed pages (Z3FOLD) [N/m/y/?] (NEW) ?

I had to read the help texts for both before I clued in that one used
two compressed pages, and the other used 3.

And 'make oldconfig' doesn't have a "Wait, what?" option to go back
to a previous prompt....

(Change Z3FOLD prompt to "New low density" or something? )

--==_Exmh_1461686910_3054P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVx+SfgdmEQWDXROgAQLH7xAAhJsnlcSoszVVrp6kfUh/SX27XFKklCjI
cgpiCEwUxpiL72GcPctSuERdXn+iUUGBbvUm9h2/ASn8QJTgAsiO1nn/XJLkmUEx
JfAna65SPTflbhPJpk7x2TEQeSj/6Dzk3VjN2y1HMp8XxJfGEVWBZlYhn5rvkW8e
vzU+BLGk3a0MVNIdr6OxuzZzHuiZlt+3+a9MJAPIvq8We28cYjnzkbarTz9Huo6X
I7pIlv6YNQkqVhT5JPCfZiGoCT8XRU3w/49Q8x3sapFFfWDOZ9gL8HiwMQh2aArT
hLn/hKgKlkGdtAS/z3obzKvT5T7irDt9fHNONIIo7uMTPuwaJpbc4JLXu7RsZ/La
Nwi7Aer/r8geaqglQC+R/+lrNOkFQAywpRcPSzRS/ePIEhSGjmcTSmVUA4urmY9L
K5B3bCAvlVnYMvbsM0NPUh4VpMtmDpmwThRTP7SQN9U3/h9Pithjr9JAcB6eII+1
4mTFdxt5WddxRixDOUUHLHRBhpu4CjsBU3k1dfuPQC1TWzqEdP5vSzXsKmLT4FiV
bJipmbWNbODB16KyEoBWWURJs2qUpya6wAdHnf2bRnxr5qGy1lWRjjGgNg3MS7uh
4A08FY0bknTpSP+J1Feu1G5IMdrRFmIp8fCFbTWMoy1ms3NaU9jyP0IhLn5Fzs6A
bRumH0eq2wg=
=Mysg
-----END PGP SIGNATURE-----

--==_Exmh_1461686910_3054P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
