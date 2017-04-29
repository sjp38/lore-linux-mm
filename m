Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFC5F6B02E1
	for <linux-mm@kvack.org>; Sat, 29 Apr 2017 10:18:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l9so8022086wre.12
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 07:18:43 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id 14si10181730wrb.329.2017.04.29.07.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Apr 2017 07:18:42 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id g12so9756749wrg.2
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 07:18:42 -0700 (PDT)
Date: Sat, 29 Apr 2017 16:18:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170429141838.tkyfxhldmwypyipz@gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>


* Dan Williams <dan.j.williams@intel.com> wrote:

> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> removed from the mm fast path if we take a single get_dev_pagemap()
> reference to signify that the page is alive and use the final put of the
> page to drop that reference.
> 
> This does require some care to make sure that any waits for the
> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> since it now maintains its own elevated reference.
> 
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

This changelog is lacking an explanation about how this solves the crashes you 
were seeing.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
