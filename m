Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6576B7411
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:27:42 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v2so14699095plg.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:27:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n78si20463150pfi.235.2018.12.05.03.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:27:41 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB5BOewU082396
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 06:27:41 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p6c65n1g1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:27:40 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Dec 2018 11:27:39 -0000
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 5 Dec 2018 16:57:17 +0530
MIME-Version: 1.0
In-Reply-To: <20181204184919.GD2937@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d90b88f6-b414-a0f9-d572-35c4d2bb1579@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/5/18 12:19 AM, Jerome Glisse wrote:

> Above example is for migrate. Here is an example for how the
> topology is use today:
> 
>      Application knows that the platform is running on have 16
>      GPU split into 2 group of 8 GPUs each. GPU in each group can
>      access each other memory with dedicated mesh links between
>      each others. Full speed no traffic bottleneck.
> 
>      Application splits its GPU computation in 2 so that each
>      partition runs on a group of interconnected GPU allowing
>      them to share the dataset.
> 
> With HMS:
>      Application can query the kernel to discover the topology of
>      system it is running on and use it to partition and balance
>      its workload accordingly. Same application should now be able
>      to run on new platform without having to adapt it to it.
> 

Will the kernel be ever involved in decision making here? Like the 
scheduler will we ever want to control how there computation units get 
scheduled onto GPU groups or GPU?

> This is kind of naive i expect topology to be hard to use but maybe
> it is just me being pesimistics. In any case today we have a chicken
> and egg problem. We do not have a standard way to expose topology so
> program that can leverage topology are only done for HPC where the
> platform is standard for few years. If we had a standard way to expose
> the topology then maybe we would see more program using it. At very
> least we could convert existing user.
> 
> 

I am wondering whether we should consider HMAT as a subset of the ideas
mentioned in this thread and see whether we can first achieve HMAT 
representation with your patch series?

-aneesh
