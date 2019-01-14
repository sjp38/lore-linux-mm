Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 684C18E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:40:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so16459299pfj.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:40:19 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760044.outbound.protection.outlook.com. [40.107.76.44])
        by mx.google.com with ESMTPS id u23si692618pfi.175.2019.01.14.08.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Jan 2019 08:40:18 -0800 (PST)
From: "Harrosh, Boaz" <Boaz.Harrosh@netapp.com>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Date: Mon, 14 Jan 2019 16:40:16 +0000
Message-ID: 
 <MWHPR06MB2896124A4B2B7C9F38383817EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>,<ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
In-Reply-To: <ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Sistare <steven.sistare@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux_lkml_grp@oracle.com" <linux_lkml_grp@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>

Sistare <steven.sistare@oracle.com> wrote:
>=20
> A better heuristic would be to return an aligned address if the length
> is a multiple of the huge page size.  The gap (if any) between the end of
> the previous VMA and the start of this VMA would be filled by subsequent
> smaller mmap requests.  The new behavior would need to become part of the
> mmap interface definition so apps can rely on it and omit their hoop-jump=
ing
> code.
>=20

Yes that was my original request

> Personally I would like to see a new MAP_ALIGN flag and treat the addr
> argument as the alignment (like Solaris),=20

Yes I would like that. So app can know when to do the old thing ...

> but I am told that adding flags
> is problematic because old kernels accept undefined flag bits from userla=
nd
> without complaint, so their behavior would change.
>=20

There is already a mechanism in place since 4.14 I think or even before on
how to add new MMAP_XXX flags. This is done by combining MMAP_SHARED & MMAP=
_PRIVATE
flags together with the new set of flags. If there are present new flags th=
is is allowed and means
requesting some new flag. Else and in old Kernels the combination above is =
not allowed in POSIX
and would fail in old Kernels.

Cheers
Boaz

> - Steve
