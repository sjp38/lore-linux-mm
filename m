Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 438796B0325
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 08:34:52 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t22-v6so12437439pfi.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 05:34:52 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g9-v6si42603904pge.245.2018.11.06.05.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 05:34:51 -0800 (PST)
Message-ID: <1541511290.7839.9.camel@intel.com>
Subject: Re: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to
 <...>_barrier()
From: Sean Christopherson <sean.j.christopherson@intel.com>
Date: Tue, 06 Nov 2018 05:34:50 -0800
In-Reply-To: <20181105211455.GB3074@bombadil.infradead.org>
References: <20181105192955.26305-1-sean.j.christopherson@intel.com>
	 <20181105121833.200d5b53300a7ef4df7d349d@linux-foundation.org>
	 <20181105211455.GB3074@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Oded Gabbay <oded.gabbay@amd.com>

On Mon, 2018-11-05 at 13:14 -0800, Matthew Wilcox wrote:
> On Mon, Nov 05, 2018 at 12:18:33PM -0800, Andrew Morton wrote:
> > 
> > > 
> > > +++ b/mm/mmu_notifier.c
> > But as it has no callers, why retain it?
> ... and this patch missed the declaration of mmu_notifier_synchronize
> in include/linux/mmu_notifier.h (whether we delete it or rename it,
> that mention of it needs to be fixed)

Doh. A I'll remove the function and send v2.
