Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 204696B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:18:05 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hi6so272890245pac.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:18:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s9si36950612pfj.41.2016.09.06.13.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 13:18:00 -0700 (PDT)
Date: Tue, 6 Sep 2016 13:17:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Message-Id: <20160906131756.6b6c6315b7dfba3a9d5f233a@linux-foundation.org>
In-Reply-To: <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
	<147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@ml01.01.org, Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

On Tue, 06 Sep 2016 09:49:41 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> track_pfn_insert() is marking dax mappings as uncacheable.
> 
> It is used to keep mappings attributes consistent across a remapped range.
> However, since dax regions are never registered via track_pfn_remap(), the
> caching mode lookup for dax pfns always returns _PAGE_CACHE_MODE_UC.  We do not
> use track_pfn_insert() in the dax-pte path, and we always want to use the
> pgprot of the vma itself, so drop this call.
> 
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
> Reported-by: Kai Zhang <kai.ka.zhang@oracle.com>
> Reported-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Changelog fails to explain the user-visible effects of the patch.  The
stable maintainer(s) will look at this and wonder "ytf was I sent
this".

After fixing that, 

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
