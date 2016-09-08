Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7466B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 18:49:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so144720782pfv.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 15:49:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r90si390799pfk.194.2016.09.08.15.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 15:49:32 -0700 (PDT)
Date: Thu, 8 Sep 2016 15:49:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: fix cache mode of dax pmd mappings
Message-Id: <20160908154931.73b8c075b8c8e4702f877bd7@linux-foundation.org>
In-Reply-To: <147328717393.35069.6384193370523015106.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
	<147328717393.35069.6384193370523015106.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@ml01.01.org, Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

On Wed, 07 Sep 2016 15:26:14 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> track_pfn_insert() in vmf_insert_pfn_pmd() is marking dax mappings as
> uncacheable rendering them impractical for application usage.  DAX-pte
> mappings are cached and the goal of establishing DAX-pmd mappings is to
> attain more performance, not dramatically less (3 orders of magnitude).
> 
> track_pfn_insert() relies on a previous call to reserve_memtype() to
> establish the expected page_cache_mode for the range.  While memremap()
> arranges for reserve_memtype() to be called, devm_memremap_pages() does
> not.  So, teach track_pfn_insert() and untrack_pfn() how to handle
> tracking without a vma, and arrange for devm_memremap_pages() to
> establish the write-back-cache reservation in the memtype tree.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

I'll grab [2/2].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
