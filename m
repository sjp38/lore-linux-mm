Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 223466B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:11:09 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y131-v6so2374982wmd.5
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:11:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 136-v6sor1963713wmu.12.2018.10.23.14.11.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:11:07 -0700 (PDT)
MIME-Version: 1.0
References: <20181020211200.255171-1-marcorr@google.com> <20181020211200.255171-2-marcorr@google.com>
 <20181022200617.GD14374@char.us.oracle.com> <20181023123355.GI32333@dhcp22.suse.cz>
In-Reply-To: <20181023123355.GI32333@dhcp22.suse.cz>
From: Marc Orr <marcorr@google.com>
Date: Tue, 23 Oct 2018 17:10:55 -0400
Message-ID: <CAA03e5ENHGQ_5WhiY=Ya+Kpz+jZsR=in5NAwtrW0p8iGqDg5Vw@mail.gmail.com>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>

Ack. The user is the 2nd patch in this series, the kvm_intel module,
which uses this version of vmalloc() to allocate vcpus across
non-contiguous memory. I will cc everyone here on that 2nd patch for
context.
Thanks,
Marc

On Tue, Oct 23, 2018 at 8:33 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 22-10-18 16:06:17, Konrad Rzeszutek Wilk wrote:
> > On Sat, Oct 20, 2018 at 02:11:59PM -0700, Marc Orr wrote:
> > > The __vmalloc_node_range() is in the include/linux/vmalloc.h file, but
> > > it's not exported so it can't be used. This patch exports the API. The
> > > motivation to export it is so that we can do aligned vmalloc's of KVM
> > > vcpus.
> >
> > Would it make more sense to change it to not have __ in front of it?
> > Also you forgot to CC the linux-mm folks. Doing that for you.
>
> Please also add a user so that we can see how the symbol is actually
> used with a short explanation why the existing API is not suitable.
>
> > >
> > > Signed-off-by: Marc Orr <marcorr@google.com>
> > > ---
> > >  mm/vmalloc.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index a728fc492557..9e7974ab1da4 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -1763,6 +1763,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> > >                       "vmalloc: allocation failure: %lu bytes", real_size);
> > >     return NULL;
> > >  }
> > > +EXPORT_SYMBOL_GPL(__vmalloc_node_range);
> > >
> > >  /**
> > >   * __vmalloc_node  -  allocate virtually contiguous memory
> > > --
> > > 2.19.1.568.g152ad8e336-goog
> > >
>
> --
> Michal Hocko
> SUSE Labs
