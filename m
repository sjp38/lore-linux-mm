Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A70F76B0003
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 17:34:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k9so2086831pgo.15
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 14:34:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e8si7089773pgf.679.2018.04.21.14.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 14:34:21 -0700 (PDT)
Date: Sat, 21 Apr 2018 14:34:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180421213401.GF14610@bombadil.infradead.org>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: viro@zeniv.linux.org.uk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 22, 2018 at 02:35:29AM +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler. For
> now, this is just documenting that the function returns
> a VM_FAULT value rather than an errno. Once all instances
> are converted, vm_fault_t will become a distinct type.
> 
> commit 1c8f422059ae ("mm: change return type to vm_fault_t")
> 
> There was an existing bug inside dax_load_hole()
> if vm_insert_mixed had failed to allocate a page table,
> we'd return VM_FAULT_NOPAGE instead of VM_FAULT_OOM.
> With new vmf_insert_mixed() this issue is addressed.
> 
> vm_insert_mixed_mkwrite has inefficiency when it returns
> an error value, driver has to convert it to vm_fault_t
> type. With new vmf_insert_mixed_mkwrite() this limitation
> will be addressed.
> 
> As new function vmf_insert_mixed_mkwrite() only called
> from fs/dax.c, so keeping both the changes in a single
> patch.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

There's a couple of minor things which could be tidied up, but not worth
doing them as a revision to this patch.
