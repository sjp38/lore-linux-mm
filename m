Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21D876B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:36:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id c18so524843pgv.8
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:36:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 88-v6si1669806pla.342.2018.02.13.11.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Feb 2018 11:36:55 -0800 (PST)
Date: Tue, 13 Feb 2018 11:36:49 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/gup: Fixed coding style error and warnings.
Message-ID: <20180213193649.GA2663@bombadil.infradead.org>
References: <20180213191722.11228-1-marioleinweber@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180213191722.11228-1-marioleinweber@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mario Leinweber <marioleinweber@web.de>
Cc: akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 13, 2018 at 02:17:22PM -0500, Mario Leinweber wrote:
>  	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
>  		int ret;
> +
>  		get_page(page);

Hi Mario,

Thanks for your patch, but this kind of change to the Linux core is not
generally welcomed.  There are a lot of people working on the core and
having whitespace changes conflict with real changes isn't a good use of
people's time.  You can practice whitespace changes in drivers/staging
before graduating to patches which change functionality.

Hope to see you back soon!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
