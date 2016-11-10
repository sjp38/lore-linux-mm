Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF8266B0289
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:22:50 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id hc3so81088577pac.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:22:50 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id l7si3779799pgl.92.2016.11.10.01.22.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:22:50 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Date: Thu, 10 Nov 2016 09:21:34 +0000
Message-ID: <20161110092134.GD9173@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <013801d23b31$f47a7cb0$dd6f7610$@alibaba-inc.com>
In-Reply-To: <013801d23b31$f47a7cb0$dd6f7610$@alibaba-inc.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F9AA990836406B4A81F9D80B981E832B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dave Hansen' <dave.hansen@intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Zi Yan' <zi.yan@cs.rutgers.edu>, 'Balbir Singh' <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>

Hi Hillf,

On Thu, Nov 10, 2016 at 05:08:07PM +0800, Hillf Danton wrote:
> On Tuesday, November 08, 2016 7:32 AM Naoya Horiguchi wrote:
> >=20
> > @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd=
_t orig_pmd)
> >  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
> >  		goto out_unlock;
> >=20
> > +	if (unlikely(!pmd_present(orig_pmd)))
> > +		goto out_unlock;
> > +
>=20
> Can we encounter a migration entry after acquiring ptl ?

I think we can. thp migration code releases ptl after converting pmd into
migration entry, so other code can see it even within ptl.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
