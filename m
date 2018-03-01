Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A73FB6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 20:31:18 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id m6-v6so2437063plt.14
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 17:31:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b81si2097848pfj.331.2018.02.28.17.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Feb 2018 17:31:17 -0800 (PST)
Date: Wed, 28 Feb 2018 17:31:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
Message-ID: <20180301013115.GA2946@bombadil.infradead.org>
References: <20180228223157.9281-1-willy@infradead.org>
 <06c145aa-db40-df72-b626-da9d45f9111d@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06c145aa-db40-df72-b626-da9d45f9111d@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

On Wed, Feb 28, 2018 at 03:22:49PM -0800, Randy Dunlap wrote:
> On 02/28/2018 02:31 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > I want to use the _mapcount field to record what a page is in use as.
> > This can help with debugging and we can also expose that information to
> > userspace through /proc/kpageflags to help diagnose memory usage (not
> > included as part of this patch set).
> 
> Hey,
> 
> Will there be updates to tools/vm/ also, or are these a different set of
> (many) flags?

Those KPF flags are the ones I was talking about.  I haven't looked into
what it takes to assign those flags yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
