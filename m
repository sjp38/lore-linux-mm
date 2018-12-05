Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10DDF6B75AC
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:20:51 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id v8so21344686ioh.11
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:20:51 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n3si3014438ioa.87.2018.12.05.10.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 10:20:49 -0800 (PST)
References: <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
Date: Wed, 5 Dec 2018 11:20:30 -0700
MIME-Version: 1.0
In-Reply-To: <20181205180756.GI3536@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-05 11:07 a.m., Jerome Glisse wrote:
>> Well multiple links are easy when you have a 'link' bus. Just add
>> another link device under the bus.
> 
> So you are telling do what i am doing in this patchset but not under
> HMS directory ?

No, it's completely different. I'm talking about creating a bus to
describe only the real hardware that links GPUs. Not creating a new
virtual tree containing a bunch of duplicate bus and device information
that already exists currently in sysfs.

>>
>> Technically, the accessibility issue is already encoded in sysfs. For
>> example, through the PCI tree you can determine which ACS bits are set
>> and determine which devices are behind the same root bridge the same way
>> we do in the kernel p2pdma subsystem. This is all bus specific which is
>> fine, but if we want to change that, we should have a common way for
>> existing buses to describe these attributes in the existing tree. The
>> new 'link' bus devices would have to have some way to describe cases if
>> memory isn't accessible in some way across it.
> 
> What i am looking at is much more complex than just access bit. It
> is a whole set of properties attach to each path (can it be cache
> coherent ? can it do atomic ? what is the access granularity ? what
> is the bandwidth ? is it dedicated link ? ...)

I'm not talking about just an access bit. I'm talking about what you are
describing: standard ways for *existing* buses in the sysfs hierarchy to
describe things like cache coherency, atomics, granularity, etc without
creating a new hierarchy.

> On top of that i argue that more people would use that information if it
> were available to them. I agree that i have no hard evidence to back that
> up and that it is just a feeling but you can not disprove me either as
> this is a chicken and egg problem, you can not prove people will not use
> an API if the API is not there to be use.

And you miss my point that much of this information is already available
to them. And more can be added in the existing framework without
creating any brand new concepts. I haven't said anything about
chicken-and-egg problems -- I've given you a bunch of different
suggestions to split this up into more managable problems and address
many of them within the APIs and frameworks we have already.

Logan
