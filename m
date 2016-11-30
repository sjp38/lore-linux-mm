Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFD086B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 22:03:54 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l192so342639899oih.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 19:03:54 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0043.outbound.protection.outlook.com. [104.47.2.43])
        by mx.google.com with ESMTPS id t37si30104007ota.55.2016.11.29.19.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 19:03:54 -0800 (PST)
Date: Wed, 30 Nov 2016 11:03:42 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 1/6] mm: hugetlb: rename some allocation functions
Message-ID: <20161130030341.GB18502@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
 <52b661c9-f4b0-3d94-cf9b-a0ffd5ecb723@suse.cz>
 <20161129085349.GA16569@sha-win-210.asiapac.arm.com>
 <d28b825d-1026-1e91-fa4e-395df3e1be86@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <d28b825d-1026-1e91-fa4e-395df3e1be86@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Tue, Nov 29, 2016 at 11:44:23AM +0100, Vlastimil Babka wrote:
> On 11/29/2016 09:53 AM, Huang Shijie wrote:
> > On Mon, Nov 28, 2016 at 02:29:03PM +0100, Vlastimil Babka wrote:
> > > On 11/14/2016 08:07 AM, Huang Shijie wrote:
> > > >  static inline bool gigantic_page_supported(void) { return true; }
> > > >  #else
> > > > +static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
> > > > +{
> > > > +	return NULL;
> > > > +}
> > > 
> > > This hunk is not explained by the description. Could belong to a later
> > > patch?
> > > 
> > 
> > Okay, I can create an extra patch to add the description for the
> > alloc_gigantic_page().
> 
> Not sure about extra patch, just move it to an existing later patch that
> relies on it?
The whole patch set has been merged to Andrew's tree, so an extra patch
is better. :)

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
