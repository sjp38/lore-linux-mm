Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73B486B7D4A
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 19:20:53 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 92so1981901qkx.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:20:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z34si216863qvz.127.2018.12.06.16.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 16:20:52 -0800 (PST)
Date: Thu, 6 Dec 2018 19:20:45 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181207002044.GI3544@redhat.com>
References: <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
 <20181206192050.GC3544@redhat.com>
 <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
 <c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
 <f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
 <20181206223935.GG3544@redhat.com>
 <c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
 <935fc14d-91f2-bc2a-f8b5-665e4145e148@deltatee.com>
 <5e6c87d5-e4ef-12e7-32bf-c163f7ff58d7@intel.com>
 <cd5cf2a6-7415-eae7-0305-004cc7db994b@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cd5cf2a6-7415-eae7-0305-004cc7db994b@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, Dec 06, 2018 at 04:48:57PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-06 4:38 p.m., Dave Hansen wrote:
> > On 12/6/18 3:28 PM, Logan Gunthorpe wrote:
> >> I didn't think this was meant to describe actual real world performance
> >> between all of the links. If that's the case all of this seems like a
> >> pipe dream to me.
> > 
> > The HMAT discussions (that I was a part of at least) settled on just
> > trying to describe what we called "sticker speed".  Nobody had an
> > expectation that you *really* had to measure everything.
> > 
> > The best we can do for any of these approaches is approximate things.
> 
> Yes, though there's a lot of caveats in this assumption alone.
> Specifically with PCI: the bus may run at however many GB/s but P2P
> through a CPU's root complexes can slow down significantly (like down to
> MB/s).
> 
> I've seen similar things across QPI: I can sometimes do P2P from
> PCI->QPI->PCI but the performance doesn't even come close to the sticker
> speed of any of those buses.
> 
> I'm not sure how anyone is going to deal with those issues, but it does
> firmly place us in world view #2 instead of #1. But, yes, I agree
> exposing information like in #2 full out to userspace, especially
> through sysfs, seems like a nightmare and I don't see anything in HMS to
> help with that. Providing an API to ask for memory (or another resource)
> that's accessible by a set of initiators and with a set of requirements
> for capabilities seems more manageable.

Note that in #1 you have bridge that fully allow to express those path
limitation. So what you just describe can be fully reported to userspace.

I explained and given examples on how program adapt their computation to
the system topology it does exist today and people are even developing new
programming langage with some of those idea baked in.

So they are people out there that already rely on such information they
just do not get it from the kernel but from a mix of various device specific
API and they have to stich everything themself and develop a database of
quirk and gotcha. My proposal is to provide a coherent kernel API where
we can sanitize that informations and report it to userspace in a single
and coherent description.

Cheers,
J�r�me
