Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBA96B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:42:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so287512206pfx.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:42:58 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 61si2915114pld.335.2017.01.25.14.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:42:57 -0800 (PST)
Date: Thu, 26 Jan 2017 01:42:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 02/12] mm: introduce page_vma_mapped_walk()
Message-ID: <20170125224253.tuqaifbx5sdosatd@black.fi.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
 <20170125182538.86249-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125182538.86249-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 25, 2017 at 09:25:28PM +0300, Kirill A. Shutemov wrote:
> The patch introduces new interface to check if a page is mapped into a vma.
> It aims to address shortcomings of page_check_address{,_transhuge}.
> 
> Existing interface is not able to handle PTE-mapped THPs: it only finds
> the first PTE. The rest lefted unnoticed.
> 
> page_vma_mapped_walk() iterates over all possible mapping of the page in the
> vma.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I broke it during removing inline wrapper. Here's fixed version.

-----------8<----------
