Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B80496B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:48:28 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c3-v6so6149264plz.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:48:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j189-v6si26084560pgd.657.2018.06.07.15.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:48:27 -0700 (PDT)
Subject: Re: [PATCH v4 2/4] mm/sparsemem: Defer the ms->section_mem_map
 clearing
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-3-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <39ec4f7c-2ef8-aaef-7034-e1f895eeb283@intel.com>
Date: Thu, 7 Jun 2018 15:47:05 -0700
MIME-Version: 1.0
In-Reply-To: <20180521101555.25610-3-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 05/21/2018 03:15 AM, Baoquan He wrote:
> In sparse_init(), if CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y, system
> will allocate one continuous memory chunk for mem maps on one node and
> populate the relevant page tables to map memory section one by one. If
> fail to populate for a certain mem section, print warning and its
> ->section_mem_map will be cleared to cancel the marking of being present.
> Like this, the number of mem sections marked as present could become
> less during sparse_init() execution.
> 
> Here just defer the ms->section_mem_map clearing if failed to populate
> its page tables until the last for_each_present_section_nr() loop. This
> is in preparation for later optimizing the mem map allocation.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Acked-By: Dave Hansen <dave.hansen@intel.com>
