Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB6DE6B0389
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:25:08 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id v4so6920514otb.0
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 09:25:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor11232812otb.161.2018.10.29.09.25.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 09:25:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
From: Jim Mattson <jmattson@google.com>
Date: Mon, 29 Oct 2018 09:25:05 -0700
Message-ID: <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <kernellwp@gmail.com>
Cc: Marc Orr <marcorr@google.com>, kvm <kvm@vger.kernel.org>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, willy@infradead.org, Sean Christopherson <sean.j.christopherson@intel.com>

On Sun, Oct 28, 2018 at 6:58 PM, Wanpeng Li <kernellwp@gmail.com> wrote:
> We have not yet encounter memory is too fragmented to allocate kvm
> related metadata in our overcommit pools, is this true requirement
> from the product environments?

Yes.
