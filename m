Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4AF66B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:11:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v26-v6so90625eds.9
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:11:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2-v6si1359582eds.184.2018.07.23.01.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 01:11:11 -0700 (PDT)
Date: Mon, 23 Jul 2018 10:11:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180723081006.GD17905@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
 <20180723070306.GB17905@dhcp22.suse.cz>
 <20180723071154.GC17905@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723071154.GC17905@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Mon 23-07-18 09:11:54, Michal Hocko wrote:
> On Mon 23-07-18 09:03:06, Michal Hocko wrote:
> > On Fri 20-07-18 17:09:02, Andrew Morton wrote:
> > [...]
> > > Please take a look?
> > 
> > Are you OK to have these in a separate patch?
> 
> Btw. I will rebase this patch once oom stuff in linux-next settles. At
> least oom_lock removal from oom_reaper will conflict.

Hmm, I have just checked Andrew's akpm and the patch is already in and
Andrew has resolved the conflict with the oom_lock patch. It just seems
that linux-next (next-20180720) doesn't have the newest mmotm tree.

Anyway, I will go with the incremental cleanup patch per Andrew's
comments as soon as linux-next catches up.

-- 
Michal Hocko
SUSE Labs
