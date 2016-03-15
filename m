Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 047126B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 12:56:36 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 124so36184803pfg.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 09:56:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xg10si2032979pab.141.2016.03.15.09.56.34
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 09:56:34 -0700 (PDT)
Date: Tue, 15 Mar 2016 19:56:16 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] thp, mlock: update unevictable-lru.txt
Message-ID: <20160315165616.GA64554@black.fi.intel.com>
References: <1458053744-40664-1-git-send-email-kirill.shutemov@linux.intel.com>
 <56E82AAE.8090003@intel.com>
 <20160315154258.GB16462@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160315154258.GB16462@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 15, 2016 at 06:42:58PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 15, 2016 at 08:30:54AM -0700, Dave Hansen wrote:
> > On 03/15/2016 07:55 AM, Kirill A. Shutemov wrote:
> > > +Transparent huge page is represented by single entry on a lru list and
> > > +therefore we can only make unevictable entire compound page, not
> > > +individual subpages.
> > 
> > A few grammar nits:
> > 
> > A transparent huge page is represented by a single entry on an lru list.
> > Therefore, we can only make unevictable an entire compound page, not
> > individual subpages.
> 
> Thanks.
> 
> > > +We handle this by forbidding mlocking PTE-mapped huge pages. This way we
> > > +keep the huge page accessible for vmscan. Under memory pressure the page
> > > +will be split, subpages from VM_LOCKED VMAs moved to unevictable lru and
> > > +the rest can be evicted.
> > 
> > What do you mean by "mlocking" in this context?  Do you mean that we
> > actually return -ESOMETHING from mlock() on PTE-mapped huge pages?  Or,
> > do you just mean that we defer treating PTE-mapped huge pages as
> > PageUnevictable() inside the kernel?
> 
> The latter.
> 
> > I think we should probably avoid saying "mlocking" when we really mean
> > "kernel-internal mlocked page handling" aka. the unevictable list.
> 
> What about
> 
> "We handle this by keeping PTE-mapped huge pages on normal LRU lists."
> 
> ?
> 
> The updated patch is below.

Err. That was the old patch.
