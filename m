Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98A116B75C8
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:48:57 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m128so17442541itd.3
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:48:57 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id u76si12481603jau.27.2018.12.05.10.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 10:48:56 -0800 (PST)
References: <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
 <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
 <20181205183314.GJ3536@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
Date: Wed, 5 Dec 2018 11:48:37 -0700
MIME-Version: 1.0
In-Reply-To: <20181205183314.GJ3536@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-05 11:33 a.m., Jerome Glisse wrote:
> If i add a a fake driver for those what would i do ? under which
> sub-system i register them ? How i express the fact that they
> connect device X,Y and Z with some properties ?

Yes this is exactly what I'm suggesting. I wouldn't call it a fake
driver, but a new struct device describing an actual device in the
system. It would be a feature of the GPU subsystem seeing this is a
feature of GPUs. Expressing that the new devices connect to a specific
set of GPUs is not a hard problem to solve.

> This is not PCIE ... you can not discover bridges and child, it
> not a tree like structure, it is a random graph (which depends
> on how the OEM wire port on the chips).

You must be able to discover that these links exist and register a
device with the system. Where else do you get the information currently?
The suggestion doesn't change anything to do with how you interact with
hardware, only how you describe the information within the kernel.

> So i have not pre-existing driver, they are not in sysfs today and
> they do not need a driver. Hence why i proposed what i proposed
> a sysfs hierarchy where i can add those "virtual" object and shows
> how they connect existing device for which we have a sysfs directory
> to symlink.

So add a new driver -- that's what I've been suggesting all along.
Having a driver not exist is no reason to not create one. I'd suggest
that if you want them to show up in the sysfs hierarchy then you do need
some kind of driver code to create a struct device. Just because the
kernel doesn't have to interact with them is no reason not to create a
struct device. It's *much* easier to create a new driver subsystem than
a whole new userspace API.

Logan
