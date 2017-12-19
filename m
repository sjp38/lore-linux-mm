Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 246F46B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:13:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so14885042pfh.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:13:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z9si9486867pll.69.2017.12.19.09.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 09:13:07 -0800 (PST)
Date: Tue, 19 Dec 2017 09:12:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: Make follow_pte_pmd an inline
Message-ID: <20171219171254.GD30842@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <1513703142.1234.53.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513703142.1234.53.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 09:05:42AM -0800, Joe Perches wrote:
> On Tue, 2017-12-19 at 08:58 -0800, Matthew Wilcox wrote:
> > +	/* (void) is needed to make gcc happy */
> > +	(void) __cond_lock(*ptlp,
> > +			   !(res = __follow_pte_pmd(mm, address, start, end,
> > +						    ptepp, pmdpp, ptlp)));
> 
> This seems obscure and difficult to read.  Perhaps:
> 
> 	res = __follow_pte_pmd(mm, address, start, end, ptepp, pmdpp, ptlp);
> 	(void)__cond_lock(*ptlp, !res);

Patch 1 moves the code.  Patch 2 cleans it up ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
