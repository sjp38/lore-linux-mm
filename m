Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D81EE6B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 08:39:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v77so2634218wrc.18
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 05:39:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l12sor3516199edk.47.2018.03.29.05.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 05:39:05 -0700 (PDT)
Date: Thu, 29 Mar 2018 15:38:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180329123829.jnwmmdtt2py32d7j@node.shutemov.name>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
 <5d334638-2139-07a1-c999-36a1729173fb@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d334638-2139-07a1-c999-36a1729173fb@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 10:15:02AM -0700, Dave Hansen wrote:
> On 03/28/2018 09:55 AM, Kirill A. Shutemov wrote:
> > @@ -51,7 +51,7 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
> >  		gfp_mask |= __GFP_HIGHMEM;
> >  
> > -	new_page = __alloc_pages_nodemask(gfp_mask, order,
> > +	new_page = __alloc_pages_nodemask(gfp_mask, order, page_keyid(page),
> >  				preferred_nid, nodemask);
> 
> You're not going to like this suggestion.
> 
> Am I looking at this too superficially, or does every single site into
> which you pass keyid also take a node and gfpmask and often an order?  I
> think you need to run this by the keepers of page_alloc.c and see if
> they'd rather do something more drastic.

Are you talking about having some kind of struct that would indicalte page
allocation context -- gfp_mask + order + node + keyid?

-- 
 Kirill A. Shutemov
