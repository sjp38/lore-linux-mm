Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB9A6B73A4
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:40:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so9328258edm.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:40:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e11si9542093edl.89.2018.12.05.01.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 01:40:17 -0800 (PST)
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz>
 <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz>
 <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz>
 <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz>
Date: Wed, 5 Dec 2018 10:40:14 +0100
MIME-Version: 1.0
In-Reply-To: <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On 12/5/18 10:29 AM, Pingfan Liu wrote:
>> [    0.007418] Early memory node ranges
>> [    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
>> [    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
>> [    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
>> [    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
>> [    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
>> [    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
>> [    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]
>>
>> There is clearly no node2. Where did the driver get the node2 from?

I don't understand these tables too much, but it seems the other nodes
exist without them:

[    0.007393] SRAT: PXM 2 -> APIC 0x20 -> Node 2

Maybe the nodes are hotplugable or something?

> Since using nr_cpus=4 , the node2 is not be instanced by x86 initalizing code.

Indeed, nr_cpus seems to restrict what nodes we allocate and populate
zonelists for.
