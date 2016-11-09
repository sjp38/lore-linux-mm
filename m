Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C29126B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:53:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so97324536pfx.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 15:53:43 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id g68si1691728pfe.278.2016.11.09.15.53.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 15:53:42 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Wed, 9 Nov 2016 23:52:25 +0000
Message-ID: <20161109235223.GA31285@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5822FB60.5040905@linux.vnet.ibm.com>
In-Reply-To: <5822FB60.5040905@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8D6B989798C35F4BA47BC60D561EFF77@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi Anshuman,

On Wed, Nov 09, 2016 at 04:03:04PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> > Hi everyone,
> >=20
> > I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> > with feedbacks for ver.1.
> >=20
> > General description (no change since ver.1)
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > This patchset enhances page migration functionality to handle thp migra=
tion
> > for various page migration's callers:
> >  - mbind(2)
> >  - move_pages(2)
> >  - migrate_pages(2)
> >  - cgroup/cpuset migration
> >  - memory hotremove
> >  - soft offline
> >=20
> > The main benefit is that we can avoid unnecessary thp splits, which hel=
ps us
> > avoid performance decrease when your applications handles NUMA optimiza=
tion on
> > their own.
> >=20
> > The implementation is similar to that of normal page migration, the key=
 point
> > is that we modify a pmd to a pmd migration entry in swap-entry like for=
mat.
>=20
> Will it be better to have new THP_MIGRATE_SUCCESS and THP_MIGRATE_FAIL
> VM events to capture how many times the migration worked without first
> splitting the huge page and how many time it did not work ?

Thank you for the suggestion.
I think that's helpful, so will try it in next version.

> Also do you
> have a test case which demonstrates this THP migration and kind of shows
> its better than the present split and move method ?

I don't have test cases which compare thp migration and split-then-migratio=
n
with some numbers. Maybe measuring/comparing the overhead of migration is
a good start point, although I think the real benefit of thp migration come=
s
from workload "after migration" by avoiding thp split.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
