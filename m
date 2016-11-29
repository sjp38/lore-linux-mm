Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352A96B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 02:53:23 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so243261480pfk.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 23:53:23 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id 79si58879891pfz.134.2016.11.28.23.53.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 23:53:22 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 04/12] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Tue, 29 Nov 2016 07:50:06 +0000
Message-ID: <20161129075006.GA15582@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161128142154.GM14788@dhcp22.suse.cz>
In-Reply-To: <20161128142154.GM14788@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9CCFE8352436764EA483008D45B714F4@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Nov 28, 2016 at 03:21:54PM +0100, Michal Hocko wrote:
> On Tue 08-11-16 08:31:49, Naoya Horiguchi wrote:
> > Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
> > functionality to x86_64, which should be safer at the first step.
>=20
> Please make sure to describe why this has to be arch specific and what
> are arches supposed to provide in order to enable this option.

OK, the below will be added in the future version:

  Thp migration is an arch-specific feature because it depends on the
  arch-dependent behavior of non-present format of page table entry.
  What you need to enable this option in other archs are:
  - to define arch-specific transformation functions like __pmd_to_swp_entr=
y()
    and __swp_entry_to_pmd(),
  - to make sure that arch-specific page table walking code can properly ha=
ndle
    !pmd_present case (gup_pmd_range() is a good example),
  - (if your archs enables CONFIG_HAVE_ARCH_SOFT_DIRTY,) to define soft dir=
ty
    routines like pmd_swp_mksoft_dirty.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
