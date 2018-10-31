Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBC86B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:19:14 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j127-v6so13708027wmd.3
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:19:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r124-v6sor6344345wmg.20.2018.10.31.14.19.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 14:19:12 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
 <20181029164813.GH28520@bombadil.infradead.org> <CAA03e5GT4gR4iN-na0PR_oTrXKVuD8BRcHcR8Y58==eRae3iXA@mail.gmail.com>
 <20181031132751.GL10491@bombadil.infradead.org> <CAA03e5F+o5svBe1HTOHukD6Z6ctnKB96+SQTfMZX39uhP2AS0g@mail.gmail.com>
 <20181031142122.GM10491@bombadil.infradead.org>
In-Reply-To: <20181031142122.GM10491@bombadil.infradead.org>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 14:19:00 -0700
Message-ID: <CAA03e5EUQf2fAgwmzoXs1JU5m3-wvb3w2TzzJ8G5bSG+3W_30A@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: Jim Mattson <jmattson@google.com>, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Wed, Oct 31, 2018 at 7:21 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Oct 31, 2018 at 01:48:44PM +0000, Marc Orr wrote:
> > Thanks for the explanation. Is there a way to dynamically detect the
> > memory allocation done by kvmalloc() (i.e., kmalloc() or vmalloc())?
> > If so, we could use kvmalloc(), and add two code paths to do the
> > physical mapping, according to whether the underlying memory was
> > allocated with kmalloc() or vmalloc().
>
> Yes -- it's used in the implementation of kvfree():
>
>         if (is_vmalloc_addr(addr))
>                 vfree(addr);
>         else
>                 kfree(addr);
>

I can drop the vmalloc() patches (unless someone else thinks we should
proceed with a kvmalloc() version). I discussed them with my
colleagues, and the consensus on our end is we shouldn't let these
structs bloat so big. Thanks for everyone's help to reduce them by 2x
the fpu struct! I'll be sending out another version of the patch
series, with the two fpu patches and minus the vmalloc() patches,
after I hear back from Dave on a question I just sent.
