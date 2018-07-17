Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7EB86B000A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:45:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n8-v6so430214wmh.0
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:45:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3-v6sor383526wrn.20.2018.07.17.04.45.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 04:45:12 -0700 (PDT)
Date: Tue, 17 Jul 2018 13:45:11 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 1/5] mm/sparse: abstract sparse buffer allocations
Message-ID: <20180717114511.GB24361@techadventures.net>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
 <20180716174447.14529-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716174447.14529-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Mon, Jul 16, 2018 at 01:44:43PM -0400, Pavel Tatashin wrote:
> When struct pages are allocated for sparse-vmemmap VA layout, we first try
> to allocate one large buffer, and than if that fails allocate struct pages
> for each section as we go.
> 
> The code that allocates buffer is uses global variables and is spread
> across several call sites.
> 
> Cleanup the code by introducing three functions to handle the global
> buffer:
> 
> sparse_buffer_init()	initialize the buffer
> sparse_buffer_fini()	free the remaining part of the buffer
> sparse_buffer_alloc()	alloc from the buffer, and if buffer is empty
> return NULL
> 
> Define these functions in sparse.c instead of sparse-vmemmap.c because
> later we will use them for non-vmemmap sparse allocations as well.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

I did not see anything wrong, so:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
