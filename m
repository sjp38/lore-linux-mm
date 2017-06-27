Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB3AD6B036A
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:40:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u126so14917503qka.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:40:03 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id p16si3421339qtb.121.2017.06.27.11.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 11:40:02 -0700 (PDT)
Received: from mr2.cc.vt.edu (mr2.cc.ipv6.vt.edu [IPv6:2607:b400:92:8400:0:90:e077:bf22])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id v5RIe2vc027741
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:40:02 -0400
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by mr2.cc.vt.edu (8.14.7/8.14.7) with ESMTP id v5RIdvGH018808
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:40:02 -0400
Received: by mail-qt0-f197.google.com with SMTP id 50so15687512qtz.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:40:02 -0700 (PDT)
From: valdis.kletnieks@vt.edu
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save pfn:1499f4
In-Reply-To: <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com> <20170624001738.GB7946@gmail.com> <20170624150824.GA19708@gmail.com> <bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz>
 <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1498588793_8534P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Jun 2017 14:39:53 -0400
Message-ID: <8643.1498588793@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Punit Agrawal <punit.agrawal@arm.com>, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrei Vagin <avagin@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Cyrill Gorcunov <gorcunov@openvz.org>

--==_Exmh_1498588793_8534P
Content-Type: text/plain; charset=us-ascii

On Tue, 27 Jun 2017 19:37:34 +0300, "Kirill A. Shutemov" said:

> > > commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
> > > Merge: 849c34f 93a7379
> > > Author: Stephen Rothwell
> > > Date:   Fri Jun 23 16:40:07 2017 +1000
> > >
> > >     Merge branch 'akpm-current/current'
> >
> > Hm is it really the merge of mmotm itself and not one of the patches in
> > mmotm?
> > Anyway smells like THP, adding Kirill.
>
> Okay, it took a while to figure it out.
>
> The bug is in patch "mm, gup: ensure real head page is ref-counted when
> using hugepages". We should look for a head *before* the loop. Otherwise
> 'page' may point to the first page beyond the compound page.
>
> The patch below should help.

Confirmed that fixes the BUGs that I was hitting.

Tested-By: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--==_Exmh_1498588793_8534P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBWVKmeY0DS38y7CIcAQJjpAf/aQ1PsbY4ZHUDDn2GSOfXbZKIflyMBCML
z/RDQh1nzdoE8hAaPfHmDznHsHLX1XSD6HU20TJK2r1tXKLZ652jVVhxwFz6o1zA
cTr5AKGuynXpOhstmJS1XF12wI16Jb87o31zT3wVwU7QbgpXnSXUdBcO7cWRgzwk
+8bTeBKpORg92K93gERbmZVLaTNEVEIssxAWXq0303KnbPnwLwEpX9LdsQ7KJtIx
7ZUYEdb9j9PzXl5Aso5r2vO6VfoMCbjb/hPtBObXKX10vwWEbLPNyx831CmYWjRl
Qm5F4mqLhBW1yplasaaK7Z86DEIr+KQ7WSmM48W94EoGGYnNc5lDSQ==
=pUDz
-----END PGP SIGNATURE-----

--==_Exmh_1498588793_8534P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
