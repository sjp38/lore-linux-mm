Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD726B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:15:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so490299511pfx.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:15:55 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0083.outbound.protection.outlook.com. [104.47.0.83])
        by mx.google.com with ESMTPS id n63si13033217pfg.16.2016.12.04.19.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 04 Dec 2016 19:15:54 -0800 (PST)
Date: Mon, 5 Dec 2016 11:15:43 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH V2 fix 5/6] mm: hugetlb: add a new function to allocate a
 new gigantic page
Message-ID: <20161205031542.GB13468@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-6-git-send-email-shijie.huang@arm.com>
 <1479279304-31379-1-git-send-email-shijie.huang@arm.com>
 <20161202140325.GM6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161202140325.GM6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Fri, Dec 02, 2016 at 03:03:30PM +0100, Michal Hocko wrote:
> On Wed 16-11-16 14:55:04, Huang Shijie wrote:
> > There are three ways we can allocate a new gigantic page:
> > 
> > 1. When the NUMA is not enabled, use alloc_gigantic_page() to get
> >    the gigantic page.
> > 
> > 2. The NUMA is enabled, but the vma is NULL.
> >    There is no memory policy we can refer to.
> >    So create a @nodes_allowed, initialize it with init_nodemask_of_mempolicy()
> >    or init_nodemask_of_node(). Then use alloc_fresh_gigantic_page() to get
> >    the gigantic page.
> > 
> > 3. The NUMA is enabled, and the vma is valid.
> >    We can follow the memory policy of the @vma.
> > 
> >    Get @nodes_allowed by huge_nodemask(), and use alloc_fresh_gigantic_page()
> >    to get the gigantic page.
> 
> Again __hugetlb_alloc_gigantic_page is not used and it is hard to deduce
> its usage from this commit. The above shouldn't be really much different from

Okay, I will merge it into the later patch.

> what we do in alloc_pages_vma so please make sure to check it before
> coming up with something hugetlb specific.
No problem. Thanks for the hint.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
