Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 722FC6B0266
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:46:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so287982605pgb.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:46:29 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p66si24762237pga.87.2017.01.25.14.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:46:28 -0800 (PST)
Date: Thu, 26 Jan 2017 01:46:24 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 07/12] mm: convert try_to_unmap_one() to
 page_vma_mapped_walk()
Message-ID: <20170125224624.3q3txzuy3tfqnyg3@black.fi.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
 <20170125182538.86249-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125182538.86249-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 25, 2017 at 09:25:33PM +0300, Kirill A. Shutemov wrote:
> +		/* Nuke the page table entry. */
> +		flush_cache_page(vma, address, pte_pfn(pvmw.pte));

This has to be 
		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));

Fixed version:

-------8<-------
