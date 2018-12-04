Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2FD66B70BF
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:19:26 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id n25so15682208iog.13
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:19:26 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id z189si6949679itb.76.2018.12.04.13.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 13:19:25 -0800 (PST)
References: <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com> <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
Date: Tue, 4 Dec 2018 14:19:09 -0700
MIME-Version: 1.0
In-Reply-To: <20181204205902.GM2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 1:59 p.m., Jerome Glisse wrote:
> How to expose harmful memory to userspace then ? How can i expose
> non cache coherent memory because yes they are application out there
> that use that today and would like to be able to migrate to and from
> that memory dynamicly during lifetime of the application as the data
> set progress through the application processing pipeline.

I'm not arguing against the purpose or use cases. I'm being critical of
the API choices.

> Note that i do not expose things like physical address or even splits
> memory in a node into individual device, in fact in expose less
> information that the existing NUMA (no zone, phys index, ...). As i do
> not think those have any value to userspace. What matter to userspace
> is where is this memory is in my topology so i can look at all the
> initiators node that are close by. Or the reverse, i have a set of
> initiators what is the set of closest targets to all those initiators.

No, what matters to applications is getting memory that will work for
the initiators/resources they need it to work for. The specific topology
might be of interest to administrators but it is not what applications
need. And it should be relatively easy to flesh out the existing sysfs
device tree to provide the topology information administrators need.

> I am talking about the inevitable fact that at some point some system
> firmware will miss-represent their platform. System firmware writer
> usualy copy and paste thing with little regards to what have change
> from one platform to the new. So their will be inevitable workaround
> and i would rather see those piling up inside a userspace library than
> inside the kernel.

It's *absolutely* the kernel's responsibility to patch issues caused by
broken firmware. We have quirks all over the place for this. That's
never something userspace should be responsible for. Really, this is the
raison d'etre of the kernel: to provide userspace with a uniform
execution environment -- if every application had to deal with broken
firmware it would be a nightmare.

Logan
