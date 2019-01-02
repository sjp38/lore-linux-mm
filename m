Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2E598E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:25:34 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d18so33573171pfe.0
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:25:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n8si47587361plp.137.2019.01.02.13.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 13:25:33 -0800 (PST)
Date: Wed, 2 Jan 2019 13:25:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [BUG, TOT] xfs w/ dax failure in __follow_pte_pmd()
Message-ID: <20190102212531.GK6310@bombadil.infradead.org>
References: <20190102211332.GL4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102211332.GL4205@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, akpm@linux-foundation.org

On Thu, Jan 03, 2019 at 08:13:32AM +1100, Dave Chinner wrote:
> Hi folks,
> 
> An overnight test run on a current TOT kernel failed generic/413
> with the following dmesg output:
> 
> [ 9487.276402] RIP: 0010:__follow_pte_pmd+0x22d/0x340
> [ 9487.305065] Call Trace:
> [ 9487.307310]  dax_entry_mkclean+0xbb/0x1f0

We've only got one commit touching dax_entry_mkclean and it's Jerome's.
Looking through ac46d4f3c43241ffa23d5bf36153a0830c0e02cc, I'd say
it's missing a call to mmu_notifier_range_init().
