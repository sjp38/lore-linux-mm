Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 480DC6B7165
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:58:27 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s14so15288049pfk.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:58:27 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f14si21188353pln.289.2018.12.04.15.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 15:58:26 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
 <20163c1e-00f1-7e02-82c0-7730ceabb9f2@intel.com>
 <20181204215711.GP2937@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ed96fdb0-d8b6-e19b-fe45-532042b712c6@intel.com>
Date: Tue, 4 Dec 2018 15:58:23 -0800
MIME-Version: 1.0
In-Reply-To: <20181204215711.GP2937@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/4/18 1:57 PM, Jerome Glisse wrote:
> Fully correct mind if i steal that perfect summary description next time
> i post ? I am so bad at explaining thing :)

Go for it!

> Intention is to allow program to do everything they do with mbind() today
> and tomorrow with the HMAT patchset and on top of that to also be able to
> do what they do today through API like OpenCL, ROCm, CUDA ... So it is one
> kernel API to rule them all ;)

While I appreciate the exhaustive scope of such a project, I'm really
worried that if we decided to use this for our "HMAT" use cases, we'll
be bottlenecked behind this project while *it* goes through 25 revisions
over 4 or 5 years like HMM did.

So, should we just "park" the enhancements to the existing NUMA
interfaces and infrastructure (think /sys/devices/system/node) and wait
for this to go in?  Do we try to develop them in parallel and make them
consistent?  Or, do we just ignore each other and make Andrew sort it
out in a few years? :)
