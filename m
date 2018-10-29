Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E351E6B049D
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 15:22:53 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y185-v6so7824362wmg.6
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:22:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor3542365wrx.38.2018.10.29.12.22.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 12:22:52 -0700 (PDT)
MIME-Version: 1.0
References: <20181026075900.111462-1-marcorr@google.com> <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
 <20181029164813.GH28520@bombadil.infradead.org> <CALMp9eSB6zW37D+0Pr-a-wXnOqE_00BHwxJ74356VujXYAcXrA@mail.gmail.com>
 <CAA03e5H2gsGmhHkTcdHjvF8nkAeBJvqa4JYEOQNNgNDnfHz1QQ@mail.gmail.com>
In-Reply-To: <CAA03e5H2gsGmhHkTcdHjvF8nkAeBJvqa4JYEOQNNgNDnfHz1QQ@mail.gmail.com>
From: Marc Orr <marcorr@google.com>
Date: Mon, 29 Oct 2018 19:22:40 +0000
Message-ID: <CAA03e5E_MbZoMjfwovx=6K+VzMfhFsdggQpyW6-6i9GDTObafQ@mail.gmail.com>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Mattson <jmattson@google.com>
Cc: willy@infradead.org, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Mon, Oct 29, 2018 at 12:16 PM Marc Orr <marcorr@google.com> wrote:
>
> Thanks for all the discussion on this. Give me a bit to investigate
> Dave's suggestions around refactoring the fpu state, and I'll report
> back with what I find.
> Thanks,
> Marc

Also, sorry for top-posting on my last email!
