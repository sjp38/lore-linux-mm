Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF8516B0006
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:22:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v126so474055pgb.21
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:22:35 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j7-v6si3264357plk.553.2018.02.15.12.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 12:22:34 -0800 (PST)
Subject: Re: [RFC PATCH 0/3] Interface for higher order contiguous allocations
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
From: Reinette Chatre <reinette.chatre@intel.com>
Message-ID: <770445b3-6caa-a87a-5de7-3157fc5280c2@intel.com>
Date: Thu, 15 Feb 2018 12:22:33 -0800
MIME-Version: 1.0
In-Reply-To: <20180212222056.9735-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

Hi Mike,

On 2/12/2018 2:20 PM, Mike Kravetz wrote:
> These patches came out of the "[RFC] mmap(MAP_CONTIG)" discussions at:
> http://lkml.kernel.org/r/21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com
> 
> One suggestion in that thread was to create a friendlier interface that
> could be used by drivers and others outside core mm code to allocate a
> contiguous set of pages.  The alloc_contig_range() interface is used for
> this purpose today by CMA and gigantic page allocation.  However, this is
> not a general purpose interface.  So, wrap alloc_contig_range() in the
> more general interface:
> 
> struct page *find_alloc_contig_pages(unsigned int order, gfp_t gfp, int nid,
> 					nodemask_t *nodemask)
> 
> No underlying changes are made to increase the likelihood that a contiguous
> set of pages can be found and allocated.  Therefore, any user of this
> interface must deal with failure.  The hope is that this interface will be
> able to satisfy some use cases today.

As discussed in another thread a new feature, Cache Pseudo-Locking,
requires large contiguous regions. Until now I just exposed
alloc_gigantic_page() to handle these allocations in my testing. I now
moved to using find_alloc_contig_pages() as introduced here and all my
tests passed. I do hope that an API supporting large contiguous regions
become available.

Thank you very much for creating this.

Tested-by: Reinette Chatre <reinette.chatre@intel.com>

Reinette

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
