Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC4E6B0266
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:38:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c206so40748619wme.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:38:31 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id u108si27857055wrc.135.2017.01.25.12.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 12:38:30 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id d140so45347467wmd.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:38:30 -0800 (PST)
Date: Wed, 25 Jan 2017 23:38:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 02/12] mm: introduce page_vma_mapped_walk()
Message-ID: <20170125203827.GA6232@node.shutemov.name>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
 <20170125182538.86249-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125182538.86249-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Please ignore, I screwed it up.

I'll repost once get it fixed and tested.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
