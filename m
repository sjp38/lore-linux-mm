Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92A636B000D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 20:08:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id p91-v6so11020700plb.12
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 17:08:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k4-v6si14457853pgo.77.2018.07.09.17.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 17:08:08 -0700 (PDT)
Date: Mon, 9 Jul 2018 17:08:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/3] sparse_init rewrite
Message-Id: <20180709170806.bc28d2affba0e903e946e057@linux-foundation.org>
In-Reply-To: <20180709235604.GA2070@MiWiFi-R3L-srv>
References: <20180709175312.11155-1-pasha.tatashin@oracle.com>
	<20180709142928.c8af4a1ddf80c407fe66b224@linux-foundation.org>
	<20180709235604.GA2070@MiWiFi-R3L-srv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Tue, 10 Jul 2018 07:56:04 +0800 Baoquan He <bhe@redhat.com> wrote:

> Hi Andrew,
> 
> On 07/09/18 at 02:29pm, Andrew Morton wrote:
> > On Mon,  9 Jul 2018 13:53:09 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> > > For the ease of review, I split this work so the first patch only adds new
> > > interfaces, the second patch enables them, and removes the old ones.
> > 
> > This clashes pretty significantly with patches from Baoquan and Oscar:
> > 
> > mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
> > mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
> > mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch
> > mm-sparse-add-a-static-variable-nr_present_sections.patch
> > mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> 
> > Is there duplication of intent here?  Any thoughts on the
> > prioritization of these efforts?
> 
> The final version of my patches was posted here:
> http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com
> 
> Currently, only the first three patches are merged. 
> 
> mm-sparse-add-a-static-variable-nr_present_sections.patch
> mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> 
> They are preparation patches, and the 4th patch is the formal fix patch:
> [PATCH v6 4/5] mm/sparse: Optimize memmap allocation during sparse_init()
> 
> The 5th patch is a clean up patch according to reviewer's suggestion:
> [PATCH v6 5/5] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> 
> I think Pavel's patches sits on top of all above five patches.

OK, thanks, I've just moved to the v6 series.
