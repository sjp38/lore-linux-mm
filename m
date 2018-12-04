Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF716B6FFA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 13:02:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so9444332pgi.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 10:02:57 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o13si15048410pgp.540.2018.12.04.10.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 10:02:56 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
Date: Tue, 4 Dec 2018 10:02:55 -0800
MIME-Version: 1.0
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/3/18 3:34 PM, jglisse@redhat.com wrote:
> This means that it is no longer sufficient to consider a flat view
> for each node in a system but for maximum performance we need to
> account for all of this new memory but also for system topology.
> This is why this proposal is unlike the HMAT proposal [1] which
> tries to extend the existing NUMA for new type of memory. Here we
> are tackling a much more profound change that depart from NUMA.

The HMAT and its implications exist, in firmware, whether or not we do
*anything* in Linux to support it or not.  Any system with an HMAT
inherently reflects the new topology, via proximity domains, whether or
not we parse the HMAT table in Linux or not.

Basically, *ACPI* has decided to extend NUMA.  Linux can either fight
that or embrace it.  Keith's HMAT patches are embracing it.  These
patches are appearing to fight it.  Agree?  Disagree?

Also, could you add a simple, example program for how someone might use
this?  I got lost in all the new sysfs and ioctl gunk.  Can you
characterize how this would work with the *exiting* NUMA interfaces that
we have?
