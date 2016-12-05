Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C96206B025E
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:06:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so337168325pgc.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:06:59 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0080.outbound.protection.outlook.com. [104.47.0.80])
        by mx.google.com with ESMTPS id q12si12999924pli.269.2016.12.04.19.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 04 Dec 2016 19:06:59 -0800 (PST)
Date: Mon, 5 Dec 2016 11:06:49 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 3/6] mm: hugetlb: change the return type for
 alloc_fresh_gigantic_page
Message-ID: <20161205030648.GB13365@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-4-git-send-email-shijie.huang@arm.com>
 <20161202135643.GK6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161202135643.GK6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Fri, Dec 02, 2016 at 02:56:43PM +0100, Michal Hocko wrote:
> On Mon 14-11-16 15:07:36, Huang Shijie wrote:
> > This patch changes the return type to "struct page*" for
> > alloc_fresh_gigantic_page().
> 
> OK, this makes somme sense. Other hugetlb allocation function (and page
> allocator in general) return struct page as well. Besides that int would
> make sense if we wanted to convey an error code but 0 vs. 1 just doesn't
> make any sense.
> 
> But if you are changing that then alloc_fresh_huge_page should be
> changed as well.
Okay.

> 
> > This patch makes preparation for later patch.
> > 
> > Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
Thanks a lot.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
