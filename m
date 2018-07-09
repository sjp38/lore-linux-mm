Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54C686B0003
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 17:29:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g20-v6so12478101pfi.2
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 14:29:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s14-v6si14709336pgn.76.2018.07.09.14.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 14:29:30 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:29:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/3] sparse_init rewrite
Message-Id: <20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
In-Reply-To: <20180709175312.11155-1-pasha.tatashin@oracle.com>
References: <20180709175312.11155-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Mon,  9 Jul 2018 13:53:09 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> In sparse_init() we allocate two large buffers to temporary hold usemap and
> memmap for the whole machine. However, we can avoid doing that if we
> changed sparse_init() to operated on per-node bases instead of doing it on
> the whole machine beforehand.
> 
> As shown by Baoquan
> http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com
> 
> The buffers are large enough to cause machine stop to boot on small memory
> systems.
> 
> These patches should be applied on top of Baoquan's work, as
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed in that work.
> 
> For the ease of review, I split this work so the first patch only adds new
> interfaces, the second patch enables them, and removes the old ones.

This clashes pretty significantly with patches from Baoquan and Oscar:

mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch
mm-sparse-add-a-static-variable-nr_present_sections.patch
mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch

Is there duplication of intent here?  Any thoughts on the
prioritization of these efforts?
