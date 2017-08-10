Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1681F6B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:23:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f11so1186793oih.7
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:23:01 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id a191si5298877oih.66.2017.08.10.09.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 09:23:00 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id o9so11547480iod.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:22:59 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:22:56 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v5 03/10] swiotlb: Map the buffer if it was unmapped by
 XPFO
Message-ID: <20170810162256.ah4yre6xjbfd5oi3@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-4-tycho@docker.com>
 <20170810130104.GB2413@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810130104.GB2413@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Thu, Aug 10, 2017 at 09:01:06AM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Aug 09, 2017 at 02:07:48PM -0600, Tycho Andersen wrote:
> > +inline bool xpfo_page_is_unmapped(struct page *page)
> > +{
> > +	if (!static_branch_unlikely(&xpfo_inited))
> > +		return false;
> > +
> > +	return test_bit(XPFO_PAGE_UNMAPPED, &lookup_xpfo(page)->flags);
> > +}
> > +EXPORT_SYMBOL(xpfo_page_is_unmapped);
> 
> How can it be inline and 'EXPORT_SYMBOL' ? And why make it inline? It
> surely does not need to be access that often?

Good point. I'll drop inline from the next version, thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
