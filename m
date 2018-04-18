Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5D76B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 21:39:18 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f6-v6so110056qth.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 18:39:18 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id s2si189392qkf.36.2018.04.17.18.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 18:39:17 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: add find_alloc_contig_pages() interface
References: <20180417020915.11786-3-mike.kravetz@oracle.com>
 <201804172011.K5f3XeGz%fengguang.wu@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b340fd3f-9400-8d47-2125-6c51e26f583c@oracle.com>
Date: Tue, 17 Apr 2018 18:39:03 -0700
MIME-Version: 1.0
In-Reply-To: <201804172011.K5f3XeGz%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/17/2018 05:10 AM, kbuild test robot wrote:
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/slab.h:15:0,
>                     from include/linux/crypto.h:24,
>                     from arch/x86/kernel/asm-offsets.c:9:
>>> include/linux/gfp.h:580:15: error: unknown type name 'page'
>     static inline page *find_alloc_contig_pages(unsigned int order, gfp_t gfp,
>                   ^~~~
>    include/linux/gfp.h:585:13: warning: 'free_contig_pages' defined but not used [-Wunused-function]
>     static void free_contig_pages(struct page *page, unsigned long nr_pages)
>                 ^~~~~~~~~~~~~~~~~

Build issues fixed in updated patch below,
