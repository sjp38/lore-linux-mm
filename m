Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5FE76B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:07:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u68so515092pfk.8
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:07:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e32-v6si15522067plb.34.2018.03.08.14.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Mar 2018 14:07:15 -0800 (PST)
Date: Thu, 8 Mar 2018 14:07:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Message-ID: <20180308220708.GA29073@bombadil.infradead.org>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
 <20180307183227.17983-2-toshi.kani@hpe.com>
 <20180308040016.GB9082@bombadil.infradead.org>
 <1520527285.2693.56.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520527285.2693.56.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <mhocko@suse.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Mar 08, 2018 at 03:56:30PM +0000, Kani, Toshi wrote:
> On Wed, 2018-03-07 at 20:00 -0800, Matthew Wilcox wrote:
> > On Wed, Mar 07, 2018 at 11:32:26AM -0700, Toshi Kani wrote:
> > > +/**
> > > + * pud_free_pmd_page - clear pud entry and free pmd page
> > > + *
> > > + * Returns 1 on success and 0 on failure (pud not cleared).
> > > + */
> > > +int pud_free_pmd_page(pud_t *pud)
> > > +{
> > > +	return pud_none(*pud);
> > > +}
> > 
> > Wouldn't it be clearer if you returned 'bool' instead of 'int' here?
> 
> I thought about it and decided to use 'int' since all other pud/pmd/pte
> interfaces, such as pud_none() above, use 'int'.

These interfaces were introduced before we had bool ... I suspect nobody's
taken the time to go through and convert them all.
