Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE6D6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:01:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so8471892plo.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:01:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x127-v6si2668580pgb.618.2018.07.20.16.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 16:01:27 -0700 (PDT)
Date: Fri, 20 Jul 2018 16:01:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-Id: <20180720160125.f3cda46f317a1ff5a2342549@linux-foundation.org>
In-Reply-To: <20180717081201.GB16803@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
	<20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
	<20180717081201.GB16803@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Tue, 17 Jul 2018 10:12:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > Any suggestions regarding how the driver developers can test this code
> > path?  I don't think we presently have a way to fake an oom-killing
> > event?  Perhaps we should add such a thing, given the problems we're
> > having with that feature.
> 
> The simplest way is to wrap an userspace code which uses these notifiers
> into a memcg and set the hard limit to hit the oom. This can be done
> e.g. after the test faults in all the mmu notifier managed memory and
> set the hard limit to something really small. Then we are looking for a
> proper process tear down.

Chances are, some of the intended audience don't know how to do this
and will either have to hunt down a lot of documentation or will just
not test it.  But we want them to test it, so a little worked step-by-step
example would help things along please.
