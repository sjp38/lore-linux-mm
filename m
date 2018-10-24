Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 412246B026B
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:22:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k17-v6so2320344edr.18
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 01:22:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4-v6si2754091edc.98.2018.10.24.01.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 01:22:19 -0700 (PDT)
Date: Wed, 24 Oct 2018 10:22:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Message-ID: <20181024082217.GC18839@dhcp22.suse.cz>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-2-marcorr@google.com>
 <20181022200617.GD14374@char.us.oracle.com>
 <20181023123355.GI32333@dhcp22.suse.cz>
 <CAA03e5ENHGQ_5WhiY=Ya+Kpz+jZsR=in5NAwtrW0p8iGqDg5Vw@mail.gmail.com>
 <20181024061650.GZ18839@dhcp22.suse.cz>
 <CAA03e5Gw1UsFRtQ2drnkXteDFj1J_+PXe0RLjXnCEytZdL4gUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5Gw1UsFRtQ2drnkXteDFj1J_+PXe0RLjXnCEytZdL4gUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>

Please do not top-post

On Wed 24-10-18 09:12:52, Marc Orr wrote:
> No. I separated them because they're going to two different subsystems
> (i.e., mm and kvm).

Yes, they do go to two different subsystems but they would have to
coordinate for the final merge because the later wouldn't work without
the former. So it is easier to have them in a single tree. From the
review POV it is better to have them in the single patch to see the
usecase for the export and judge whether this is the best option.

> I'll fold them and resend the patch.

Thanks!

> On Wed, Oct 24, 2018 at 7:16 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 23-10-18 17:10:55, Marc Orr wrote:
> > > Ack. The user is the 2nd patch in this series, the kvm_intel module,
> > > which uses this version of vmalloc() to allocate vcpus across
> > > non-contiguous memory. I will cc everyone here on that 2nd patch for
> > > context.
> >
> > Is there any reason to not fold those two into a single one?
> > --
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs
