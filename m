Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61B4D6B757C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:31:01 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id v8so8984297ioq.5
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:31:01 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id a7si12223856jai.54.2018.12.05.09.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 09:30:59 -0800 (PST)
References: <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <CAPcyv4ihEesx1G1on6JA8qZ6RooOsgO2CL_=1gXVMXpMJW_N9w@mail.gmail.com>
 <20181205023724.GF3045@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <2f53e0c0-a8af-b003-5bd7-a341431908df@deltatee.com>
Date: Wed, 5 Dec 2018 10:25:31 -0700
MIME-Version: 1.0
In-Reply-To: <20181205023724.GF3045@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 7:37 p.m., Jerome Glisse wrote:
>>
>> This came up before for apis even better defined than HMS as well as
>> more limited scope, i.e. experimental ABI availability only for -rc
>> kernels. Linus said this:
>>
>> "There are no loopholes. No "but it's been only one release". No, no,
>> no. The whole point is that users are supposed to be able to *trust*
>> the kernel. If we do something, we keep on doing it.
>>
>> And if it makes it harder to add new user-visible interfaces, then
>> that's a *good* thing." [1]
>>
>> The takeaway being don't land work-in-progress ABIs in the kernel.
>> Once an application depends on it, there are no more incompatible
>> changes possible regardless of the warnings, experimental notices, or
>> "staging" designation. DAX is experimental because there are cases
>> where it currently does not work with respect to another kernel
>> feature like xfs-reflink, RDMA. The plan is to fix those, not continue
>> to hide behind an experimental designation, and fix them in a way that
>> preserves the user visible behavior that has already been exposed,
>> i.e. no regressions.
>>
>> [1]: https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2017-August/004742.html
> 
> So i guess i am heading down the vXX road ... such is my life :)

I recommend against it. I really haven't been convinced by any of your
arguments for having a second topology tree. The existing topology tree
in sysfs already better describes the links between hardware right now,
except for the missing GPU links (and those should be addressable within
the GPU community). Plus, maybe, some other enhancements to sockets/numa
node descriptions if there's something missing there.

Then, 'hbind' is another issue but I suspect it would be better
implemented as an ioctl on existing GPU interfaces. I certainly can't
see any benefit in using it myself.

It's better to take an approach that would be less controversial with
the community than to brow beat them with a patch set 20+ times until
they take it.

Logan
