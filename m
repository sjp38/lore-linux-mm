Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E10F6B0010
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 17:24:37 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id a126-v6so13697963wmf.4
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 14:24:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 59-v6sor2703629wro.34.2018.10.31.14.24.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 14:24:36 -0700 (PDT)
MIME-Version: 1.0
References: <20181031132634.50440-1-marcorr@google.com> <20181031132634.50440-3-marcorr@google.com>
 <cf476e07-e2fc-45c9-7259-3952a5cbb30e@intel.com> <CAA03e5HmMq-+9WsJ+Kd05ary85A7HJ5HJbNMUzc87QCRxamJGg@mail.gmail.com>
 <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com>
In-Reply-To: <4094fe59-a161-99f0-e3cd-7ac14eb9f5a4@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Wed, 31 Oct 2018 14:24:24 -0700
Message-ID: <CAA03e5F7LsYcrr6fgHWdwQ=hyYm2Su7Lqke7==Un7tSp57JtSA@mail.gmail.com>
Subject: Re: [kvm PATCH v5 2/4] kvm: x86: Dynamically allocate guest_fpu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

> It can get set to sizeof(struct fregs_state) for systems where XSAVE is
> not in use.  I was neglecting to mention those when I said the "~500
> byte" number.
>
> My point was that it can vary wildly and that any static allocation
> scheme will waste lots of memory when we have small hardware-supported
> buffers.

Got it. Then I think we need to set the size for the kmem cache to
max(fpu_kernel_xstate_size, sizeof(fxregs_state)), unless I'm missing
something. I'll send out a version of the patch that does this in a
bit. Thanks!
