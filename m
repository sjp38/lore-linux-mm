Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C73646B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 19:56:11 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c3-v6so25296000qkb.2
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 16:56:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u46-v6si6044859qvc.146.2018.07.09.16.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 16:56:10 -0700 (PDT)
Date: Tue, 10 Jul 2018 07:56:04 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v4 0/3] sparse_init rewrite
Message-ID: <20180709235604.GA2070@MiWiFi-R3L-srv>
References: <20180709175312.11155-1-pasha.tatashin@oracle.com>
 <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

Hi Andrew,

On 07/09/18 at 02:29pm, Andrew Morton wrote:
> On Mon,  9 Jul 2018 13:53:09 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> > For the ease of review, I split this work so the first patch only adds new
> > interfaces, the second patch enables them, and removes the old ones.
> 
> This clashes pretty significantly with patches from Baoquan and Oscar:
> 
> mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
> mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch
> mm-sparse-add-a-static-variable-nr_present_sections.patch
> mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch

> Is there duplication of intent here?  Any thoughts on the
> prioritization of these efforts?

The final version of my patches was posted here:
http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com

Currently, only the first three patches are merged. 

mm-sparse-add-a-static-variable-nr_present_sections.patch
mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch

They are preparation patches, and the 4th patch is the formal fix patch:
[PATCH v6 4/5] mm/sparse: Optimize memmap allocation during sparse_init()

The 5th patch is a clean up patch according to reviewer's suggestion:
[PATCH v6 5/5] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER

I think Pavel's patches sits on top of all above five patches.

Thanks
Baoquan
