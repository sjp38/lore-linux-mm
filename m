Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 550D48E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 13:30:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so2512663pgv.8
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 10:30:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w14si494032plq.145.2019.01.08.10.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 Jan 2019 10:30:06 -0800 (PST)
Date: Tue, 8 Jan 2019 10:29:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4] mm: Create the new vm_fault_t type
Message-ID: <20190108182959.GD6310@bombadil.infradead.org>
References: <20190108183041.GA12137@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108183041.GA12137@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, rppt@linux.ibm.com, mhocko@suse.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, william.kucharski@oracle.com

On Wed, Jan 09, 2019 at 12:00:41AM +0530, Souptick Joarder wrote:
> Page fault handlers are supposed to return VM_FAULT codes,
> but some drivers/file systems mistakenly return error
> numbers. Now that all drivers/file systems have been converted
> to use the vm_fault_t return type, change the type definition
> to no longer be compatible with 'int'. By making it an unsigned
> int, the function prototype becomes incompatible with a function
> which returns int. Sparse will detect any attempts to return a
> value which is not a VM_FAULT code.
> 
> VM_FAULT_SET_HINDEX and VM_FAULT_GET_HINDEX values are changed
> to avoid conflict with other VM_FAULT codes.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
