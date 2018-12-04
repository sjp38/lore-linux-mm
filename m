Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFDA16B6D7C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:20:26 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so7714877edd.11
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:20:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19-v6sor4424890ejv.42.2018.12.03.23.20.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 23:20:25 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com> <20181204065453.4rsyhtsk2aej4vim@master>
In-Reply-To: <20181204065453.4rsyhtsk2aej4vim@master>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Dec 2018 15:20:13 +0800
Message-ID: <CAFgQCTvQBC11=4eGQ6T9vyB+KOznFCr4hjdg1wwD8GotSRWpDg@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard.weiyang@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 4, 2018 at 2:54 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>
> On Tue, Dec 04, 2018 at 11:05:57AM +0800, Pingfan Liu wrote:
> >During my test on some AMD machine, with kexec -l nr_cpus=x option, the
> >kernel failed to bootup, because some node's data struct can not be allocated,
> >e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
> >device->numa_node info is used as preferred_nid param for
>
> could we fix the preferred_nid before passed to
> __alloc_pages_nodemask()?
>
Yes, we can doit too, but what is the gain?

> BTW, I don't catch the function call flow to this point. Would you mind
> giving me some hint?
>
You can track the code along slab_alloc() ->...->__alloc_pages_nodemask()

Thanks,
Pingfan
