Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75ACD6B03BD
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:12:57 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d34so7180329otb.10
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:12:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor10892204oty.66.2018.10.29.11.12.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:12:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181029164813.GH28520@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com> <20181029164813.GH28520@bombadil.infradead.org>
From: Jim Mattson <jmattson@google.com>
Date: Mon, 29 Oct 2018 11:12:54 -0700
Message-ID: <CALMp9eSB6zW37D+0Pr-a-wXnOqE_00BHwxJ74356VujXYAcXrA@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wanpeng Li <kernellwp@gmail.com>, Marc Orr <marcorr@google.com>, kvm <kvm@vger.kernel.org>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, Sean Christopherson <sean.j.christopherson@intel.com>

On Mon, Oct 29, 2018 at 9:48 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, Oct 29, 2018 at 09:25:05AM -0700, Jim Mattson wrote:
>> On Sun, Oct 28, 2018 at 6:58 PM, Wanpeng Li <kernellwp@gmail.com> wrote:
>> > We have not yet encounter memory is too fragmented to allocate kvm
>> > related metadata in our overcommit pools, is this true requirement
>> > from the product environments?
>>
>> Yes.
>
> Are your logs granular enough to determine if turning this into an
> order-2 allocation (by splitting out "struct fpu" allocations) will be
> sufficient to resolve your problem, or do we need to turn it into an
> order-1 or vmalloc allocation to achieve your production goals?

Turning this into an order-2 allocation should suffice.
