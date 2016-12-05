Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A8B816B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:05:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so489572962pfb.7
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:05:37 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10082.outbound.protection.outlook.com. [40.107.1.82])
        by mx.google.com with ESMTPS id 31si13002214plj.195.2016.12.04.19.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 04 Dec 2016 19:05:36 -0800 (PST)
Date: Mon, 5 Dec 2016 11:05:26 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 2/6] mm: hugetlb: add a new parameter for some
 functions
Message-ID: <20161205030525.GA13365@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-3-git-send-email-shijie.huang@arm.com>
 <20161202135229.GJ6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161202135229.GJ6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Fri, Dec 02, 2016 at 02:52:30PM +0100, Michal Hocko wrote:
> On Mon 14-11-16 15:07:35, Huang Shijie wrote:
> > This patch adds a new parameter, the "no_init", for these functions:
> >    alloc_fresh_gigantic_page_node()
> >    alloc_fresh_gigantic_page()
> > 
> > The prep_new_huge_page() does some initialization for the new page.
> > But sometime, we do not need it to do so, such as in the surplus case
> > in later patch.
> > 
> > With this parameter, the prep_new_huge_page() can be called by needed:
> >    If the "no_init" is false, calls the prep_new_huge_page() in
> >    the alloc_fresh_gigantic_page_node();
> 
> This double negative just makes my head spin. I haven't got to later
> patch to understand the motivation but if anything bool do_prep would
> be much more clear. In general doing these "init if a parameter is
Okay, I will use the "do_prep" for the new parameter.

thanks for the code review.

Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
