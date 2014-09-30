Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id E7BC16B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 16:38:05 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id c9so3016123qcz.36
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 13:38:05 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2001:468:c80:2105:0:2fc:76e3:30de])
        by mx.google.com with ESMTPS id c4si20094122qab.24.2014.09.30.13.38.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Sep 2014 13:38:05 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Tue, 30 Sep 2014 12:08:41 -0400."
             <20140930160841.GB5098@wil.cx>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx> <123795.1412088827@turing-police.cc.vt.edu>
            <20140930160841.GB5098@wil.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412109476_2351P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Sep 2014 16:37:56 -0400
Message-ID: <15704.1412109476@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1412109476_2351P
Content-Type: text/plain; charset=us-ascii

On Tue, 30 Sep 2014 12:08:41 -0400, Matthew Wilcox said:

> The more I think about this, the more I think this is a bad idea.
> When you have a file open with O_DIRECT, your I/O has to be done in
> 512-byte multiples, and it has to be aligned to 512-byte boundaries
> in memory.  If an unsuspecting application has O_DIRECT forced on it,
> it isn't going to know to do that, and so all its I/Os will fail.

I'm thinking of more than one place where that would be a feature, not a bug. :)

> What problem are you really trying to solve?  Some big files hogging
> the page cache?

I'm officially a storage admin.  I mostly support HPC and research. As
such, I'm always looking to add tools to my toolkit. :)

(And yes, I fully recognize that *in general*, this is a Bad Idea.  However,
when you've got That One Problem Data File that *should* always be access
via O_DIRECT, and *usually* is accessed via O_DIRECT, and bad things happen
if something accesses it without it (for instance, when the file is 1.5X the
actual RAM), you start looking for fixes.  If you've got another, more
sustainable way to say "do not let file /X/Y/Z hog the page cache" (and
no, LD_PRELOAD isn't sustainable the way chattr is, in my book), feel free to
recommend something. :)

--==_Exmh_1412109476_2351P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCsUpAdmEQWDXROgAQLtTRAAmtXKDrrOZeySpwTh/yTcggA+raNc/s5a
JNtd72eORjwW4YHTyx0fYOYjNx6n04pSfermhjN2szEc5ZvsVMOd3mS/I59E4QeT
833VEQa+FrqxiumBPxzvj2ZBqYuCShRa8Aa+eWnWOTvKuxEwVcho++Uut17dzTG1
MDHrbWoM6FEM2qLgjW1oIONGbk78aJqpJAWiKxyWBx0ZGcDC5NxWHw3Vp3gQhtCn
oUZZ2NxcL/DPODTJMJB7JfQm2moTCpVjUMsRVWIDArzyQW2GSt/tcOqt3MbjxUBN
tYdfhfSMXxB2buuqTw5l+x+dSmG3custEGse7oLpi0NezG+aso0VGeH8nXhqficF
0b98nVIyt/8JNM7iBwfZezrnJVu75TWVW2xI9wIsoRUPK/7BWTZiqsHomiryXi+G
kDyOq6OT+0EBsdO5OuDJHvHne7o0mUCPP1SVBQzJw4bC/1V4nyDy0Utqwb06YBZX
fc3Sk7kK5ESADwYvyrxasWqlOQ6E7Mgek1rOIToxp4+doVL6m5AIDwR3aQIvHcCq
EszeA54fRmdBQ53fCTsBLHPHHH7WE03tMPbmgIUyQnRBO24IQA1QBdz5Tdg86JcS
fRZShu0JKmCr5SlYuY+S/Jd2coSfcvZXDW1Mh6aUGddY+CEoTtUpAv/1TaJSQRjK
mWndn0n6yUU=
=5HML
-----END PGP SIGNATURE-----

--==_Exmh_1412109476_2351P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
