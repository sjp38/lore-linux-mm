Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA8236B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 04:58:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so28592528pga.4
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 01:58:29 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50084.outbound.protection.outlook.com. [40.107.5.84])
        by mx.google.com with ESMTPS id b128si32969294pgc.336.2016.12.09.01.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 01:58:28 -0800 (PST)
Date: Fri, 9 Dec 2016 17:58:03 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161209095801.GA4405@sha-win-210.asiapac.arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
 <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
 <20161207150237.GC31797@dhcp22.suse.cz>
 <20161208093623.GA4551@sha-win-210.asiapac.arm.com>
 <20161208095253.GB8330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161208095253.GB8330@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will
 Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Thu, Dec 08, 2016 at 10:52:54AM +0100, Michal Hocko wrote:
> On Thu 08-12-16 17:36:24, Huang Shijie wrote:
> > On Wed, Dec 07, 2016 at 11:02:38PM +0800, Michal Hocko wrote:
> [...]
> > > I haven't yet checked your patchset but I can tell you one thing.
> >
> > Could you please review the patch set when you have time? Thanks a lot.
> 
> From a quick glance you do not handle the reservation code at all. You
Thanks, I will study the code again, and try to find What we need to do
with the reservation code.

> just make sure that the allocation doesn't fail unconditionally. I might
> be wrong here and Naoya resp. Mike will know much better but this seems
> far from enough to me.
> 
> Well, this would take me quite some time and basically restudy the whole
> hugetlb code again. What you are trying to achieve is not a simple "fix
> a test case" thing. You are trying to implement full featured giga pages
> suport. And as I've said this requires a deeper understanding of the
> current code and clean it up considerably wrt. giga pages. This is
> definitely desirable plan longterm and I would like to encourage you for
> that but it is not a simple project at the same time. 
Okay, I will try to implement the full featured giga pages support. :)

But I feel confused at the "full featured". If the patch set can pass
all the giga pages tests in the libhugetlbfs, can we say it is "full
featured"? Or some one reviews this patch set, and say it is full
featured support for the giga pages.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
