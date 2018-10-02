Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4076B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 12:03:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s1-v6so384906pfm.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 09:03:42 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b21-v6si8635846pfj.49.2018.10.02.09.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 09:03:41 -0700 (PDT)
Date: Tue, 2 Oct 2018 10:05:58 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 6/6] mm/gup: Cache dev_pagemap while pinning pages
Message-ID: <20181002160558.GA17231@localhost.localdomain>
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-7-keith.busch@intel.com>
 <20181002112623.zlxtcclhtslfx3pa@black.fi.intel.com>
 <5bb265e9-bc23-799a-ad01-30edbc762996@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5bb265e9-bc23-799a-ad01-30edbc762996@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 08:49:39AM -0700, Dave Hansen wrote:
> On 10/02/2018 04:26 AM, Kirill A. Shutemov wrote:
> >> +	page = follow_page_mask(vma, address, foll_flags, &ctx);
> >> +	if (ctx.pgmap)
> >> +		put_dev_pagemap(ctx.pgmap);
> >> +	return page;
> >>  }
> > Do we still want to keep the function as inline? I don't think so.
> > Let's move it into mm/gup.c and make struct follow_page_context private to
> > the file.
> 
> Yeah, and let's have a put_follow_page_context() that does the
> put_dev_pagemap() rather than spreading that if() to each call site.

Thanks for all the feedback. I will make a new version, but with the
gup_benchmark part split into an independent set since it is logically
separate from the final patch.
