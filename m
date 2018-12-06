Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD5C6B77BB
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 22:07:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so10987137edc.9
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 19:07:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5-v6sor5858838ejp.23.2018.12.05.19.07.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 19:07:45 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz> <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz> <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz> <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz>
In-Reply-To: <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 6 Dec 2018 11:07:33 +0800
Message-ID: <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Wed, Dec 5, 2018 at 5:40 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 12/5/18 10:29 AM, Pingfan Liu wrote:
> >> [    0.007418] Early memory node ranges
> >> [    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> >> [    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> >> [    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> >> [    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> >> [    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> >> [    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> >> [    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> >>
> >> There is clearly no node2. Where did the driver get the node2 from?
>
> I don't understand these tables too much, but it seems the other nodes
> exist without them:
>
> [    0.007393] SRAT: PXM 2 -> APIC 0x20 -> Node 2
>
> Maybe the nodes are hotplugable or something?
>
I also not sure about it, and just have a hurry look at acpi spec. I
will reply it on another email, and Cced some acpi guys about it

> > Since using nr_cpus=4 , the node2 is not be instanced by x86 initalizing code.
>
> Indeed, nr_cpus seems to restrict what nodes we allocate and populate
> zonelists for.

Yes, in init_cpu_to_node(),  since nr_cpus limits the possible cpu,
which affects the loop for_each_possible_cpu(cpu) and skip the node2
in this case.

Thanks,
Pingfan
