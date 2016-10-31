Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4E3E6B029B
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 16:40:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i128so76236412wme.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 13:40:00 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id ht7si31830940wjb.163.2016.10.31.13.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 13:39:59 -0700 (PDT)
Subject: Re: mmotm 2016-10-27-18-27 uploaded
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <CAP=VYLqNv8p_ojkcjeWCN-nMumDg296UkV1b460KDHAXOHZSEA@mail.gmail.com>
References: <5812a9b6.OlAMBhewokz9/Mou%akpm@linux-foundation.org>
 <CAP=VYLqNv8p_ojkcjeWCN-nMumDg296UkV1b460KDHAXOHZSEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1477946270_20678P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 31 Oct 2016 16:37:50 -0400
Message-ID: <21418.1477946270@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.cz>, broonie@kernel.org

--==_Exmh_1477946270_20678P
Content-Type: text/plain; charset=us-ascii

On Sun, 30 Oct 2016 14:15:30 -0400, Paul Gortmaker said:
> On Thu, Oct 27, 2016 at 9:28 PM,  <akpm@linux-foundation.org> wrote:
> > The mm-of-the-moment snapshot 2016-10-27-18-27 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
>
> Just a heads up:
>
> Somehow one of the akpm commits as it appears in linux-next has had
> spaces replaced with garbage chars:
>
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/scripts/get_maintainer.pl?id=b67071653d3fc9f9b73aab3e7978f060728bf392

How... special.  They're 0xA0 non-breaking-space chars.  Somebody's
editor was obviously in the wrong mode. :)



--==_Exmh_1477946270_20678P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.5 07/13/2001

iQEVAwUBWBerno0DS38y7CIcAQLP2Qf+NdAaDANAToJLVajkwVYVDGOxMb8pwJBN
1gowWGHDALNepgrYZXAp/SL6zwc7DTScE6RXbj0hiv0aMXsENXcB2DP9et/HX1st
PB2BPOjVCLhjL6vNW57WOlUlb4YgGdwoE7Ba06sJH/YbAGLCnwxYuhoz4e6bwHFU
BkXDCbdZRVE3xstXpM0ZBJrZ1tiZW6dQ4RXb12pHhlrBHIDtdnhksvOFgz9CemxY
PWRQS4vZbWAQza6g89H6f3QZEBc1A82K1RtV7gtObrwrpQhZvKpxXOYpwx9yg2pP
Md5jjbmye4yBsFLsap7jH0Z37gyAaFBKFAJapVnv/b75p2gFc1sgCg==
=XuS+
-----END PGP SIGNATURE-----

--==_Exmh_1477946270_20678P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
