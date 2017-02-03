Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8318A6B0038
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 22:12:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v184so8745356pgv.6
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 19:12:36 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id j19si19462697pgn.187.2017.02.02.19.12.33
        for <linux-mm@kvack.org>;
        Thu, 02 Feb 2017 19:12:35 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com> <b6f7dd5d-47aa-0ec2-b18a-bb4074ab2a2a@linux.vnet.ibm.com> <5890EB58.3050100@cs.rutgers.edu>
In-Reply-To: <5890EB58.3050100@cs.rutgers.edu>
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Fri, 03 Feb 2017 11:12:12 +0800
Message-ID: <004601d27dcb$509327a0$f1b976e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Zi Yan' <zi.yan@cs.rutgers.edu>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Balbir Singh' <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>


On February 01, 2017 3:54 AM Zi Yan wrote: 
> 
> I am also doing some tests on THP migration and discover that there are
> some corner cases not handled in this patchset.
> 
> For example, in handle_mm_fault, without taking pmd_lock, the kernel may
> see pmd_none(*pmd) during THP migrations, which leads to
> handle_pte_fault or even deeper in the code path. At that moment,
> pmd_trans_unstable() will treat a pmd_migration_entry as pmd_bad and
> clear it. This leads to application crashing and page table leaks, since
> a deposited PTE page is not released when the application crashes.
> 
> Even after I add is_pmd_migration_entry() into pmd_trans_unstable(), I
> still see application data corruptions.
> 
> I hope someone can shed some light on how to debug this. Should I also
> look into pmd_trans_huge() call sites where pmd_migration_entry should
> be handled differently?
> 
Hm ... seems it helps more if you post your current works as RFC on
top of the mm tree, and the relevant tests as well.

Hillf
> 
> Anshuman Khandual wrote:
> > On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> >> Hi everyone,
> >>
> >> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> >> with feedbacks for ver.1.
> >
> > Hello Noaya,
> >
> > I have been working with Zi Yan on the parallel huge page migration series
> > (https://lkml.org/lkml/2016/11/22/457) and planning to post them on top of
> > this THP migration enhancement series. Hence we were wondering if you have
> > plans to post a new version of this series in near future ?
> >
> > Regards
> > Anshuman
> >
> 
> --
> Best Regards,
> Yan Zi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
