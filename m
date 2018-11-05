Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCB96B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:15:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j13-v6so10639220pff.0
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:15:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o13-v6si42848376pgh.61.2018.11.05.13.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Nov 2018 13:14:58 -0800 (PST)
Date: Mon, 5 Nov 2018 13:14:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to
 <...>_barrier()
Message-ID: <20181105211455.GB3074@bombadil.infradead.org>
References: <20181105192955.26305-1-sean.j.christopherson@intel.com>
 <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sean Christopherson <sean.j.christopherson@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Oded Gabbay <oded.gabbay@amd.com>

On Mon, Nov 05, 2018 at 12:18:33PM -0800, Andrew Morton wrote:
> > +++ b/mm/mmu_notifier.c
> 
> But as it has no callers, why retain it?

... and this patch missed the declaration of mmu_notifier_synchronize
in include/linux/mmu_notifier.h (whether we delete it or rename it,
that mention of it needs to be fixed)
