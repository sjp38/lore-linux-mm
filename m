Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D82E26B028B
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:28:43 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id fp5so57702732pac.6
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:28:43 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id r4si3771840pgr.239.2016.11.10.01.28.41
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 01:28:43 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com> <013801d23b31$f47a7cb0$dd6f7610$@alibaba-inc.com> <20161110092134.GD9173@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20161110092134.GD9173@hori1.linux.bs1.fc.nec.co.jp>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common path
Date: Thu, 10 Nov 2016 17:28:20 +0800
Message-ID: <014b01d23b34$c7a71600$56f54200$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dave Hansen' <dave.hansen@intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Zi Yan' <zi.yan@cs.rutgers.edu>, 'Balbir Singh' <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>

On Thursday, November 10, 2016 5:22 PM Naoya Horiguchi wrote:
> On Thu, Nov 10, 2016 at 05:08:07PM +0800, Hillf Danton wrote:
> > On Tuesday, November 08, 2016 7:32 AM Naoya Horiguchi wrote:
> > >
> > > @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
> > >  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
> > >  		goto out_unlock;
> > >
> > > +	if (unlikely(!pmd_present(orig_pmd)))
> > > +		goto out_unlock;
> > > +
> >
> > Can we encounter a migration entry after acquiring ptl ?
> 
> I think we can. thp migration code releases ptl after converting pmd into
> migration entry, so other code can see it even within ptl.
> 
But we have a pmd_same check there, you see. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
