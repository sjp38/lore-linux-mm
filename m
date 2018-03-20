Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB44F6B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:33:29 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f4-v6so949207plr.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:33:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e61-v6si1465299plb.190.2018.03.20.04.33.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 04:33:28 -0700 (PDT)
Date: Tue, 20 Mar 2018 12:33:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm/hmm: HMM should have a callback before MM is
 destroyed
Message-ID: <20180320113326.GJ23100@dhcp22.suse.cz>
References: <20180315183700.3843-1-jglisse@redhat.com>
 <20180315183700.3843-4-jglisse@redhat.com>
 <20180315154829.89054bfd579d03097b0f6457@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315154829.89054bfd579d03097b0f6457@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Thu 15-03-18 15:48:29, Andrew Morton wrote:
> On Thu, 15 Mar 2018 14:36:59 -0400 jglisse@redhat.com wrote:
> 
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > The hmm_mirror_register() function registers a callback for when
> > the CPU pagetable is modified. Normally, the device driver will
> > call hmm_mirror_unregister() when the process using the device is
> > finished. However, if the process exits uncleanly, the struct_mm
> > can be destroyed with no warning to the device driver.
> 
> The changelog doesn't tell us what the runtime effects of the bug are. 
> This makes it hard for me to answer the "did Jerome consider doing
> cc:stable" question.

There is no upstream user of this code IIRC, so does it make sense to
mark anything for stable trees?
-- 
Michal Hocko
SUSE Labs
