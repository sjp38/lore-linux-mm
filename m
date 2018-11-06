Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5FD6B0323
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 08:26:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x14-v6so5462366edr.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 05:26:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f30-v6si606373edc.18.2018.11.06.05.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 05:26:33 -0800 (PST)
Date: Tue, 6 Nov 2018 14:26:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mmu_notifier: rename mmu_notifier_synchronize() to
 <...>_barrier()
Message-ID: <20181106132632.GD2453@dhcp22.suse.cz>
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

On Mon 05-11-18 12:18:33, Andrew Morton wrote:
> On Mon,  5 Nov 2018 11:29:55 -0800 Sean Christopherson <sean.j.christopherson@intel.com> wrote:
[...]
> > -EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
> > +EXPORT_SYMBOL_GPL(mmu_notifier_barrier);
> >  
> >  /*
> >   * This function can't run concurrently against mmu_notifier_register
> 
> But as it has no callers, why retain it?

Exported symbols are not freed and if this is not used by any in-kernel
code then I would just remove it.

-- 
Michal Hocko
SUSE Labs
