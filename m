Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7676B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:43:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r9-v6so132326edh.14
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:43:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d39-v6si958612ede.334.2018.07.23.01.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 01:43:39 -0700 (PDT)
Date: Mon, 23 Jul 2018 10:43:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180723084336.GH17905@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
 <20180717081201.GB16803@dhcp22.suse.cz>
 <20180720160125.f3cda46f317a1ff5a2342549@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720160125.f3cda46f317a1ff5a2342549@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Fri 20-07-18 16:01:25, Andrew Morton wrote:
> On Tue, 17 Jul 2018 10:12:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > Any suggestions regarding how the driver developers can test this code
> > > path?  I don't think we presently have a way to fake an oom-killing
> > > event?  Perhaps we should add such a thing, given the problems we're
> > > having with that feature.
> > 
> > The simplest way is to wrap an userspace code which uses these notifiers
> > into a memcg and set the hard limit to hit the oom. This can be done
> > e.g. after the test faults in all the mmu notifier managed memory and
> > set the hard limit to something really small. Then we are looking for a
> > proper process tear down.
> 
> Chances are, some of the intended audience don't know how to do this
> and will either have to hunt down a lot of documentation or will just
> not test it.  But we want them to test it, so a little worked step-by-step
> example would help things along please.

I am willing to give more specific steps. Is anybody interested? From my
experience so far this is not something drivers developers using mmu
notifiers would be unfamiliar with.

-- 
Michal Hocko
SUSE Labs
