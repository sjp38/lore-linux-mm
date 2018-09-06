Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 317246B7878
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:17:42 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v52-v6so10796339qtc.3
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:17:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o20-v6sor2065363qta.58.2018.09.06.04.17.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 04:17:41 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Date: Thu, 06 Sep 2018 07:17:38 -0400
Message-ID: <5526DAD7-00AB-45D0-B14C-0B8C78A17C3F@cs.rutgers.edu>
In-Reply-To: <2208ad4d-e5eb-fc53-cdc8-a351f2b6b9d1@suse.cz>
References: <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <2208ad4d-e5eb-fc53-cdc8-a351f2b6b9d1@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_51544ED5-FD1F-4082-99F8-5530E3BFCD86_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_51544ED5-FD1F-4082-99F8-5530E3BFCD86_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 6 Sep 2018, at 6:59, Vlastimil Babka wrote:

> On 08/30/2018 12:54 AM, Zi Yan wrote:
>>
>> Thanks for your patch.
>>
>> I tested it against Linus=E2=80=99s tree with =E2=80=9Cmemhog -r3 130g=
=E2=80=9D in a two-socket machine with 128GB memory on
>> each node and got the results below. I expect this test should fill on=
e node, then fall back to the other.
>>
>> 1. madvise(MADV_HUGEPAGE) + defrag =3D {always, madvise, defer+madvise=
}: no swap, THPs are allocated in the fallback node.
>> 2. madvise(MADV_HUGEPAGE) + defrag =3D defer: pages got swapped to the=
 disk instead of being allocated in the fallback node.
>
> Hmm this is GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE=
=2E
> No direct reclaim, so it would have to be kswapd causing the swapping? =
I
> wouldn't expect it to be significant and over-reclaiming. What exactly
> is your definition of "pages got swapped"?

About 4GB pages are swapped to the disk (my swap disk size is 4.7GB).
My machine has 128GB memory in each node and memhog uses 130GB memory.
When one node is filled up, the oldest pages are swapped into disk
until memhog finishes touching all 130GB memory.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_51544ED5-FD1F-4082-99F8-5530E3BFCD86_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluRDNIWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzG+BB/4nHTfGNyOdEaEzV3mCiQWIjz5k
N6rDTzVsENOq4UB09cM0iusMf4xfh0/QhvMCT/yjbd/d3R6u5zXRshSPdwi7RCrA
QoIUpsPmktuWqOe34gXc9LqEYTS/GupsqLM7UpVdvptmxffUunYZ37AAGMYrH2Qj
+yxvgOhurIhW/fmnPEJQ/3UIWy7vv0rYdq8NbjsIGFSAi94hcXCFKdhoxXd+RDHA
4EWlXNBk3aUT/ZHn7lxMcJjWhELzYMO4sdlo05ikJnSh9Eee3msB6+qokg3b3co1
HyKs2D/f3EaKBE7QcYDzN6K9DHIqA9lrjr8KqF0zYIkzBAjnynkG6dsoKG4d
=IYXf
-----END PGP SIGNATURE-----

--=_MailMate_51544ED5-FD1F-4082-99F8-5530E3BFCD86_=--
