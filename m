Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 516576B0269
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:13:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so3236452wrr.4
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 01:13:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor104369wmd.18.2018.10.24.01.13.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 01:13:05 -0700 (PDT)
MIME-Version: 1.0
References: <20181020211200.255171-1-marcorr@google.com> <20181020211200.255171-2-marcorr@google.com>
 <20181022200617.GD14374@char.us.oracle.com> <20181023123355.GI32333@dhcp22.suse.cz>
 <CAA03e5ENHGQ_5WhiY=Ya+Kpz+jZsR=in5NAwtrW0p8iGqDg5Vw@mail.gmail.com> <20181024061650.GZ18839@dhcp22.suse.cz>
In-Reply-To: <20181024061650.GZ18839@dhcp22.suse.cz>
From: Marc Orr <marcorr@google.com>
Date: Wed, 24 Oct 2018 09:12:52 +0100
Message-ID: <CAA03e5Gw1UsFRtQ2drnkXteDFj1J_+PXe0RLjXnCEytZdL4gUw@mail.gmail.com>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>

No. I separated them because they're going to two different subsystems
(i.e., mm and kvm). I'll fold them and resend the patch.
Thanks,
Marc
On Wed, Oct 24, 2018 at 7:16 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 23-10-18 17:10:55, Marc Orr wrote:
> > Ack. The user is the 2nd patch in this series, the kvm_intel module,
> > which uses this version of vmalloc() to allocate vcpus across
> > non-contiguous memory. I will cc everyone here on that 2nd patch for
> > context.
>
> Is there any reason to not fold those two into a single one?
> --
> Michal Hocko
> SUSE Labs
