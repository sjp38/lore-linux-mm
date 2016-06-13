Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44AFB6B027B
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 17:01:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b126so121551312ite.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:01:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d8si19694433paz.87.2016.06.13.14.01.52
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 14:01:52 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Date: Mon, 13 Jun 2016 21:01:48 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023FA41E@IRSMSX103.ger.corp.intel.com>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com>
 <D6EDEBF1F91015459DB866AC4EE162CC023F8EBE@IRSMSX103.ger.corp.intel.com>
 <57598E3E.3010705@intel.com>
In-Reply-To: <57598E3E.3010705@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "mingli199x@qq.com" <mingli199x@qq.com>, "minchan@kernel.org" <minchan@kernel.org>
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On 09-06-16 17:42:00, Dave Hansen wrote:
> Does your workload put large pages in and out of those pvecs, though?
> If your system doesn't have any activity, then all we've shown is that
> they're not a problem when not in use.  But what about when we use them?

It doesn't. To use them extensively I guess we would have to
craft a separate program for each one, which is not trivial.

> Have you, for instance, tried this on a system with memory pressure?

Not then, but here are exemplary snapshots with system using swap to handle=
=20
allocation requests with patch applied: (notation: pages =3D sum in bytes):
LRU_add              336 =3D     1344kB
LRU_rotate           158 =3D      632kB
LRU_deactivate         0 =3D        0kB
LRU_deact_file         0 =3D        0kB
LRU_activate           1 =3D        4kB
---
LRU_add             3262 =3D    13048kB
LRU_rotate           142 =3D      568kB
LRU_deactivate         0 =3D        0kB
LRU_deact_file         0 =3D        0kB
LRU_activate           6 =3D       24kB
---
LRU_add             3689 =3D    14756kB
LRU_rotate            81 =3D      324kB
LRU_deactivate         0 =3D        0kB
LRU_deact_file         0 =3D        0kB
LRU_activate          19 =3D       76kB

While running idle os we have:
LRU_add             1038 =3D     4152kB
LRU_rotate             0 =3D        0kB
LRU_deactivate         0 =3D        0kB
LRU_deact_file         0 =3D        0kB
LRU_activate           0 =3D        0kB

I know those are not representative in overall.

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
