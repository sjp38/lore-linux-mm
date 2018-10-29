Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D75286B049C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 15:16:47 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j6-v6so700851wre.1
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:16:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z185-v6sor1826409wmz.10.2018.10.29.12.16.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 12:16:46 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
 <20181029164813.GH28520@bombadil.infradead.org> <CALMp9eSB6zW37D+0Pr-a-wXnOqE_00BHwxJ74356VujXYAcXrA@mail.gmail.com>
In-Reply-To: <CALMp9eSB6zW37D+0Pr-a-wXnOqE_00BHwxJ74356VujXYAcXrA@mail.gmail.com>
From: Marc Orr <marcorr@google.com>
Date: Mon, 29 Oct 2018 19:16:33 +0000
Message-ID: <CAA03e5H2gsGmhHkTcdHjvF8nkAeBJvqa4JYEOQNNgNDnfHz1QQ@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Mattson <jmattson@google.com>
Cc: willy@infradead.org, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

Thanks for all the discussion on this. Give me a bit to investigate
Dave's suggestions around refactoring the fpu state, and I'll report
back with what I find.
Thanks,
Marc
On Mon, Oct 29, 2018 at 11:12 AM Jim Mattson <jmattson@google.com> wrote:
>
> On Mon, Oct 29, 2018 at 9:48 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Mon, Oct 29, 2018 at 09:25:05AM -0700, Jim Mattson wrote:
> >> On Sun, Oct 28, 2018 at 6:58 PM, Wanpeng Li <kernellwp@gmail.com> wrote:
> >> > We have not yet encounter memory is too fragmented to allocate kvm
> >> > related metadata in our overcommit pools, is this true requirement
> >> > from the product environments?
> >>
> >> Yes.
> >
> > Are your logs granular enough to determine if turning this into an
> > order-2 allocation (by splitting out "struct fpu" allocations) will be
> > sufficient to resolve your problem, or do we need to turn it into an
> > order-1 or vmalloc allocation to achieve your production goals?
>
> Turning this into an order-2 allocation should suffice.
