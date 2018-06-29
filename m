Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAB96B000D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:47:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a3-v6so4816058wrr.12
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:47:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3-v6sor645864wmc.34.2018.06.29.09.47.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 09:47:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180629140224.205849-1-shakeelb@google.com> <20180629143044.GF5963@dhcp22.suse.cz>
 <efdb8e40-742e-d120-6589-96b4fdf83cb9@redhat.com> <20180629145513.GG5963@dhcp22.suse.cz>
In-Reply-To: <20180629145513.GG5963@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 29 Jun 2018 09:47:37 -0700
Message-ID: <CALvZod4wW0-bzM1AQCnAaMpLOzOdEzLVhf0LCqe3dmMyCSCsmw@mail.gmail.com>
Subject: Re: [PATCH v2] kvm, mm: account shadow page tables to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, stable@vger.kernel.org

On Fri, Jun 29, 2018 at 7:55 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 29-06-18 16:40:23, Paolo Bonzini wrote:
> > On 29/06/2018 16:30, Michal Hocko wrote:
> > > I am not familiar wtih kvm to judge but if we are going to account this
> > > memory we will probably want to let oom_badness know how much memory
> > > to account to a specific process. Is this something that we can do?
> > > We will probably need a new MM_KERNEL rss_stat stat for that purpose.
> > >
> > > Just to make it clear. I am not opposing to this patch but considering
> > > that shadow page tables might consume a lot of memory it would be good
> > > to know who is responsible for it from the OOM perspective. Something to
> > > solve on top of this.
> >
> > The amount of memory is generally proportional to the size of the
> > virtual machine memory, which is reflected directly into RSS.  Because
> > KVM processes are usually huge, and will probably dwarf everything else
> > in the system (except firefox and chromium of course :)), the general
> > order of magnitude of the oom_badness should be okay.
>
> I think we will need MM_KERNEL longterm anyway. As I've said this is not
> a must for this patch to go. But it is better to have a fair comparision
> and kill larger processes if at all possible. It seems this should be
> the case here.
>

I will look more into MM_KERNEL counter. I still have couple more kmem
allocations in kvm (like dirty bitmap) which I want to be accounted. I
will bundle them together.

thanks,
Shakeel
