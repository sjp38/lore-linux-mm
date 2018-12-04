Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81DD46B70D5
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:37:58 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so9766466pgv.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:37:58 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si16647834pgi.480.2018.12.04.13.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:37:57 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <20163c1e-00f1-7e02-82c0-7730ceabb9f2@intel.com>
Date: Tue, 4 Dec 2018 13:37:56 -0800
MIME-Version: 1.0
In-Reply-To: <20181204184919.GD2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/4/18 10:49 AM, Jerome Glisse wrote:
>> Also, could you add a simple, example program for how someone might use
>> this?  I got lost in all the new sysfs and ioctl gunk.  Can you
>> characterize how this would work with the *exiting* NUMA interfaces that
>> we have?
> That is the issue i can not expose device memory as NUMA node as
> device memory is not cache coherent on AMD and Intel platform today.
> 
> More over in some case that memory is not visible at all by the CPU
> which is not something you can express in the current NUMA node.

Yeah, our NUMA mechanisms are for managing memory that the kernel itself
manages in the "normal" allocator and supports a full feature set on.
That has a bunch of implications, like that the memory is cache coherent
and accessible from everywhere.

The HMAT patches only comprehend this "normal" memory, which is why
we're extending the existing /sys/devices/system/node infrastructure.

This series has a much more aggressive goal, which is comprehending the
connections of every memory-target to every memory-initiator, no matter
who is managing the memory, who can access it, or what it can be used for.

Theoretically, HMS could be used for everything that we're doing with
/sys/devices/system/node, as long as it's tied back into the existing
NUMA infrastructure _somehow_.

Right?
