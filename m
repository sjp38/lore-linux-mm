Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 212386B038E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:48:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b8-v6so725677pls.11
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 09:48:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j38-v6si4591089pgl.138.2018.10.29.09.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Oct 2018 09:48:18 -0700 (PDT)
Date: Mon, 29 Oct 2018 09:48:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Message-ID: <20181029164813.GH28520@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com>
 <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Mattson <jmattson@google.com>
Cc: Wanpeng Li <kernellwp@gmail.com>, Marc Orr <marcorr@google.com>, kvm <kvm@vger.kernel.org>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, Sean Christopherson <sean.j.christopherson@intel.com>

On Mon, Oct 29, 2018 at 09:25:05AM -0700, Jim Mattson wrote:
> On Sun, Oct 28, 2018 at 6:58 PM, Wanpeng Li <kernellwp@gmail.com> wrote:
> > We have not yet encounter memory is too fragmented to allocate kvm
> > related metadata in our overcommit pools, is this true requirement
> > from the product environments?
> 
> Yes.

Are your logs granular enough to determine if turning this into an
order-2 allocation (by splitting out "struct fpu" allocations) will be
sufficient to resolve your problem, or do we need to turn it into an
order-1 or vmalloc allocation to achieve your production goals?
