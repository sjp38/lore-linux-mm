Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2C86B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:43:01 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l68so155999169wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:43:01 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id p3si33525899wjy.59.2016.03.15.08.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 08:43:00 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id p65so150524807wmp.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:43:00 -0700 (PDT)
Date: Tue, 15 Mar 2016 18:42:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp, mlock: update unevictable-lru.txt
Message-ID: <20160315154258.GB16462@node.shutemov.name>
References: <1458053744-40664-1-git-send-email-kirill.shutemov@linux.intel.com>
 <56E82AAE.8090003@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E82AAE.8090003@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 15, 2016 at 08:30:54AM -0700, Dave Hansen wrote:
> On 03/15/2016 07:55 AM, Kirill A. Shutemov wrote:
> > +Transparent huge page is represented by single entry on a lru list and
> > +therefore we can only make unevictable entire compound page, not
> > +individual subpages.
> 
> A few grammar nits:
> 
> A transparent huge page is represented by a single entry on an lru list.
> Therefore, we can only make unevictable an entire compound page, not
> individual subpages.

Thanks.

> > +We handle this by forbidding mlocking PTE-mapped huge pages. This way we
> > +keep the huge page accessible for vmscan. Under memory pressure the page
> > +will be split, subpages from VM_LOCKED VMAs moved to unevictable lru and
> > +the rest can be evicted.
> 
> What do you mean by "mlocking" in this context?  Do you mean that we
> actually return -ESOMETHING from mlock() on PTE-mapped huge pages?  Or,
> do you just mean that we defer treating PTE-mapped huge pages as
> PageUnevictable() inside the kernel?

The latter.

> I think we should probably avoid saying "mlocking" when we really mean
> "kernel-internal mlocked page handling" aka. the unevictable list.

What about

"We handle this by keeping PTE-mapped huge pages on normal LRU lists."

?

The updated patch is below.
