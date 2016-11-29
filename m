Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B16CF6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:00:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so415907773pga.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:00:31 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id r1si58809642pfd.81.2016.11.29.00.00.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 00:00:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd
 migration
Date: Tue, 29 Nov 2016 07:57:58 +0000
Message-ID: <20161129075757.GB15582@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161128143132.GN14788@dhcp22.suse.cz>
In-Reply-To: <20161128143132.GN14788@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5DF570CF9EF06C4DB6A4A0F6B59C8DB6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Nov 28, 2016 at 03:31:32PM +0100, Michal Hocko wrote:
> On Tue 08-11-16 08:31:50, Naoya Horiguchi wrote:
> > This patch prepares thp migration's core code. These code will be open =
when
> > unmap_and_move() stops unconditionally splitting thp and get_new_page()=
 starts
> > to allocate destination thps.
>=20
> this description is underdocumented to say the least. Could you
> provide a high level documentation here please?

Yes, I'll do.

And maybe some update on Documentation/vm/page_migration will be wanted,
so will do it too.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
