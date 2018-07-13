Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA4A6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:09:52 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so5348203wru.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:09:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor1633080wma.3.2018.07.13.02.09.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 02:09:50 -0700 (PDT)
Date: Fri, 13 Jul 2018 11:09:49 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 5/5] mm/sparse: delete old sprase_init and enable new
 one
Message-ID: <20180713090949.GA15039@techadventures.net>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-6-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712203730.8703-6-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

  
> -#ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -static void __init sparse_early_mem_maps_alloc_node(void *data,
> -				 unsigned long pnum_begin,
> -				 unsigned long pnum_end,
> -				 unsigned long map_count, int nodeid)
> -{
> -	struct page **map_map = (struct page **)data;
> -
> -	sparse_buffer_init(section_map_size() * map_count, nodeid);
> -	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
> -					 map_count, nodeid);
> -	sparse_buffer_fini();
> -}

>From now on, sparse_mem_maps_populate_node() is not being used anymore, so I guess we can just
remove it from sparse.c, right? (as it is done in sparse-vmemmap.c).
-- 
Oscar Salvador
SUSE L3
