Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 571596B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 13:10:43 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id c9so719644qcz.8
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 10:10:43 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2001:468:c80:2105:0:24d:7091:8b9c])
        by mx.google.com with ESMTPS id d32si2741151qgf.62.2014.10.01.10.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 10:10:42 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Wed, 01 Oct 2014 11:45:47 -0400."
             <x49r3yrn68k.fsf@segfault.boston.devel.redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx> <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx> <15704.1412109476@turing-police.cc.vt.edu> <A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca> <62749.1412113956@turing-police.cc.vt.edu>
            <x49r3yrn68k.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412183429_2347P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 01 Oct 2014 13:10:29 -0400
Message-ID: <9056.1412183429@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andreas Dilger <adilger@dilger.ca>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1412183429_2347P
Content-Type: text/plain; charset=us-ascii

On Wed, 01 Oct 2014 11:45:47 -0400, Jeff Moyer said:

> This sounds an awful lot like posix_fadvise' POSIX_FADV_NOREUSE flag.

Gaah.  No wonder 'man madvise' worked but 'man fadvise' came up empty :)

-ENOCAFFIENE :)

--==_Exmh_1412183429_2347P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCw1hQdmEQWDXROgAQJsPg/9EGdZtaCeB6xXvoTMD7Hr3g3Qs4Mj5naC
tNM/hAPT1UnTx6O0QkRhWvL4nbqlkdyhYCoXqJcHDFcGRVC9z//mJahuT+cOiV+H
UrNrsVfk3UeCiZjFyTjQoGYVJSWt26K0mYfLEgjW4dIs4j0xRJNWjNPQ7PJKRQNW
IeciK8aKqylutF1mciszvbMYFKTDiYLx7L8wQV0L0N1UUNcxUR7XyvFCbKV25eSr
71CC1tNwbBxy8F2u3YYjgGY6emHAYGR19lZLuX+Ut9uA6ez/3eRR30Bc6PzAQmPM
m0jZGMbhB4+Bb5H//sCVcyuAkG0Npjm2P1/Q4gHlELuGS9rbNwM5v5sJs3MiU2N0
C0+uM/a2XfaPwNld7UUCQCVqv+c/dZ8FZzT/y5a0f2V0e/6STkNjohqUgzkwRAC9
ZuyF9Jucm0GV72y0hdwVGUc6IOZD7eB5sIzIPoW8fxWF4T57nx6mcAhw2+Ob7kq6
gyTK9Nc0cUnhj7kpet4KG+Cs/r8onlbqXPityBPfOOaCmldXRPBo/V1rXST4nic0
bZuV5jx3qa+lw0xCEITdBasV/e/I/WF1l+FU3fQsi667KoLTHkNXClaJbj8d9yp4
q+I/CWHtNi2Ojw80xhtZwQf2bV2Y/t9l2/7io3vJzRtgIJKeIliImTRUsqxh4LHf
E5ZWHfLBzZc=
=mR70
-----END PGP SIGNATURE-----

--==_Exmh_1412183429_2347P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
