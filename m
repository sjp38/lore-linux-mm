Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC34A6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:24:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so244165156pfk.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:24:05 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id i10si48454667pgc.63.2016.11.29.00.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 00:24:04 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 06/12] mm: thp: enable thp migration in generic path
Date: Tue, 29 Nov 2016 08:16:08 +0000
Message-ID: <20161129081607.GC15582@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161128143331.GO14788@dhcp22.suse.cz>
In-Reply-To: <20161128143331.GO14788@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1650E9A2E016004B8CA537B0D06B1EB9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Nov 28, 2016 at 03:33:32PM +0100, Michal Hocko wrote:
> On Tue 08-11-16 08:31:51, Naoya Horiguchi wrote:
> > This patch makes it possible to support thp migration gradually. If you=
 fail
> > to allocate a destination page as a thp, you just split the source thp =
as we
> > do now, and then enter the normal page migration. If you succeed to all=
ocate
> > destination thp, you enter thp migration. Subsequent patches actually e=
nable
> > thp migration for each caller of page migration by allowing its get_new=
_page()
> > callback to allocate thps.
>=20
> Does this need to be in a separate patch? Wouldn't it make more sense to
> have the full THP migration code in a single one?

Actually, no big reason for separate patch. So I'm OK to merge this into
patch 5/12.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
