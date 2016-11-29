Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 320876B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:54:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so418330609pga.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:54:03 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30071.outbound.protection.outlook.com. [40.107.3.71])
        by mx.google.com with ESMTPS id g28si59056120pfd.130.2016.11.29.00.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 00:54:02 -0800 (PST)
Date: Tue, 29 Nov 2016 16:53:51 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 1/6] mm: hugetlb: rename some allocation functions
Message-ID: <20161129085349.GA16569@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
 <52b661c9-f4b0-3d94-cf9b-a0ffd5ecb723@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <52b661c9-f4b0-3d94-cf9b-a0ffd5ecb723@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon, Nov 28, 2016 at 02:29:03PM +0100, Vlastimil Babka wrote:
> On 11/14/2016 08:07 AM, Huang Shijie wrote:
> >  static inline bool gigantic_page_supported(void) { return true; }
> >  #else
> > +static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
> > +{
> > +	return NULL;
> > +}
> 
> This hunk is not explained by the description. Could belong to a later
> patch?
> 

Okay, I can create an extra patch to add the description for the
alloc_gigantic_page().

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
