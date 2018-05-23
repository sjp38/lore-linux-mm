Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 668676B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 07:18:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56-v6so17246692wrc.5
        for <linux-mm@kvack.org>; Wed, 23 May 2018 04:18:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 46-v6si1712131edu.103.2018.05.23.04.18.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 04:18:12 -0700 (PDT)
Subject: Re: [PATCH v2 3/4] mm: add find_alloc_contig_pages() interface
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
 <20180503232935.22539-4-mike.kravetz@oracle.com>
 <eaa40ac0-365b-fd27-e096-b171ed28888f@suse.cz>
 <57dfd52c-22a5-5546-f8f3-848f21710cc1@oracle.com>
 <c7972da1-a908-7550-7253-9de9a963174c@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <01793788-1870-858e-2061-a0e6ef3a3171@suse.cz>
Date: Wed, 23 May 2018 13:18:10 +0200
MIME-Version: 1.0
In-Reply-To: <c7972da1-a908-7550-7253-9de9a963174c@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reinette Chatre <reinette.chatre@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/22/2018 06:41 PM, Reinette Chatre wrote:
> On 5/21/2018 4:48 PM, Mike Kravetz wrote:
>> I'm guessing that most (?all?) allocations will be order based.  The use
>> cases I am aware of (hugetlbfs, Intel Cache Pseudo-Locking, RDMA) are all
>> order based.  However, as commented in previous version taking arbitrary
>> nr_pages makes interface more future proof.
>>
> 
> I noticed this Cache Pseudo-Locking statement and would like to clarify.
> I have not been following this thread in detail so I would like to
> apologize first if my comments are out of context.
> 
> Currently the Cache Pseudo-Locking allocations are order based because I
> assumed it was required by the allocator. The contiguous regions needed
> by Cache Pseudo-Locking will not always be order based - instead it is
> based on the granularity of the cache allocation. One example is a
> platform with 55MB L3 cache that can be divided into 20 equal portions.
> To support Cache Pseudo-Locking on this platform we need to be able to
> allocate contiguous regions at increments of 2816KB (the size of each
> portion). In support of this example platform regions needed would thus
> be 2816KB, 5632KB, 8448KB, etc.

Will there be any alignment requirements for these allocations e.g. for
minimizing conflict misses?

Vlastimil
