Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D01166B7556
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:49:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so10161448edc.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:49:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d19si2341025edy.436.2018.12.05.08.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:49:33 -0800 (PST)
Date: Wed, 5 Dec 2018 17:49:32 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end callback
Message-ID: <20181205164932.GI30615@quack2.suse.cz>
References: <20181205053628.3210-1-jglisse@redhat.com>
 <20181205053628.3210-2-jglisse@redhat.com>
 <20181205163520.GG30615@quack2.suse.cz>
 <20181205164052.GE3536@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205164052.GE3536@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed 05-12-18 11:40:52, Jerome Glisse wrote:
> On Wed, Dec 05, 2018 at 05:35:20PM +0100, Jan Kara wrote:
> > On Wed 05-12-18 00:36:26, jglisse@redhat.com wrote:
> > > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > > index 5119ff846769..5f6665ae3ee2 100644
> > > --- a/mm/mmu_notifier.c
> > > +++ b/mm/mmu_notifier.c
> > > @@ -178,14 +178,20 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > >  				  unsigned long start, unsigned long end,
> > >  				  bool blockable)
> > >  {
> > > +	struct mmu_notifier_range _range, *range = &_range;
> > 
> > Why these games with two variables?
> 
> This is a temporary step i dediced to do the convertion in 2 steps,
> first i convert the callback to use the structure so that people
> having mmu notifier callback only have to review this patch and do
> not get distracted by the second step which update all the mm call
> site that trigger invalidation.
> 
> In the final result this code disappear. I did it that way to make
> the thing more reviewable. Sorry if that is a bit confusing.

Aha, right. Thanks for clarification. You can add:

Acked-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
