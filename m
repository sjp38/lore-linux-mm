Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 469906B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 07:54:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j13-v6so6369712pgp.16
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:54:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10-v6si15721083plv.1.2018.07.02.04.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 04:54:29 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:54:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180702115423.GK19043@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>

On Mon 02-07-18 11:14:58, Christian Konig wrote:
> Am 27.06.2018 um 09:44 schrieb Michal Hocko:
> > This is the v2 of RFC based on the feedback I've received so far. The
> > code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
> > because I have no idea how.
> > 
> > Any further feedback is highly appreciated of course.
> 
> That sounds like it should work and at least the amdgpu changes now look
> good to me on first glance.
> 
> Can you split that up further in the usual way? E.g. adding the blockable
> flag in one patch and fixing all implementations of the MMU notifier in
> follow up patches.

But such a code would be broken, no? Ignoring the blockable state will
simply lead to lockups until the fixup parts get applied.
Is the split up really worth it? I was thinking about that but had hard
times to end up with something that would be bisectable. Well, except
for returning -EBUSY until all notifiers are implemented. Which I found
confusing.

> This way I'm pretty sure Felix and I can give an rb on the amdgpu/amdkfd
> changes.

If you are worried to give r-b only for those then this can be done even
for larger patches. Just make your Reviewd-by more specific
R-b: name # For BLA BLA
-- 
Michal Hocko
SUSE Labs
