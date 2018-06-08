Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9DE6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 10:20:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id p91-v6so7382165plb.12
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 07:20:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b2-v6si46054927pgc.569.2018.06.08.07.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 07:20:47 -0700 (PDT)
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
 <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
 <20180608062733.GB16231@MiWiFi-R3L-srv>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <74359df3-76a8-6dc7-51c5-27019130224f@intel.com>
Date: Fri, 8 Jun 2018 07:20:47 -0700
MIME-Version: 1.0
In-Reply-To: <20180608062733.GB16231@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/07/2018 11:27 PM, Baoquan He wrote:
> In alloc_usemap_and_memmap(), it will call
> sparse_early_usemaps_alloc_node() or sparse_early_mem_maps_alloc_node()
> to allocate usemap and memmap for each node and install them into
> usemap_map[] and map_map[]. Here we need pass in the number of present
> sections on this node so that we can move pointer of usemap_map[] and
> map_map[] to right position.
> 
> How do think about above words?

But you're now passing in the size of the data structure.  Why is that
needed all of a sudden?
