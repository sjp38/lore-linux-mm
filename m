Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id D94B56B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 01:29:21 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id ts10so97515006obc.1
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 22:29:21 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id r200si8282130oie.31.2016.03.06.22.29.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Mar 2016 22:29:21 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 02/11] mm: thp: introduce
 CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
Date: Mon, 7 Mar 2016 06:28:54 +0000
Message-ID: <20160307062853.GA31458@hori1.linux.bs1.fc.nec.co.jp>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1456990918-30906-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160307005804.GA25148@cotter.ozlabs.ibm.com>
In-Reply-To: <20160307005804.GA25148@cotter.ozlabs.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D5CEA2EE74625F40B2934D3DA5B24C5E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Mar 07, 2016 at 11:58:04AM +1100, Balbir Singh wrote:
> On Thu, Mar 03, 2016 at 04:41:49PM +0900, Naoya Horiguchi wrote:
> > Introduces CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION to limit thp migration
> > functionality to x86_64, which should be safer at the first step.
> >
>=20
> The changelog is not helpful. Could you please describe what is
> architecture specific in these changes? What do other arches need to do
> to port these changes over?

The arch specific parts are pmd_present() and swap entry format. Currently
pmd_present() in x86_64 is not simple enough to easily determine pmd's stat=
e
(none, normal pmd entry pointing to pte page, pmd for thp, or pmd migration=
 entry ...)
That requires me to assume in this version that pmd migration entry should
have_PAGE_PSE set, which should not be necessary if the complexity is fixed=
.
So I will mention this pmd_present() problem in the next version.

So if it's fixed, what developers need to do to port this feature to their
architectures is just to enable CONFIG_ARCH_ENABLE_THP_MIGRATION (and test =
it.)

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
