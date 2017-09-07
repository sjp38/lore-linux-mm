Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F82E6B0310
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 14:44:17 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 77so413399itj.7
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 11:44:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k198sor87905itk.129.2017.09.07.11.44.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 11:44:16 -0700 (PDT)
Date: Thu, 7 Sep 2017 12:44:14 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 04/11] swiotlb: Map the buffer if it was unmapped by
 XPFO
Message-ID: <20170907184414.ow7av6wt5vht6pnd@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-5-tycho@docker.com>
 <20170907181015.GA9557@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907181015.GA9557@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 07, 2017 at 11:10:15AM -0700, Christoph Hellwig wrote:
> > -	if (PageHighMem(pfn_to_page(pfn))) {
> > +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
> 
> Please don't sprinkle xpfo details over various bits of code.
> 
> Just add a helper with a descriptive name, e.g.
> 
> page_is_unmapped()
> 
> that also includes the highmem case, as that will easily document
> what this check is doing.

Will do, thanks.

Patch 7 has a similar feel to this one, I can add a wrapper around
__clean_dcache_area_pou() if that makes sense?

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
