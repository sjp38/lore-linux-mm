Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C083C6B466E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:24:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p9so13429471pfj.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:24:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k72sor3721348pge.39.2018.11.26.23.24.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:24:51 -0800 (PST)
Date: Tue, 27 Nov 2018 10:24:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/10] mm/huge_memory: rename freeze_page() to
 unmap_page()
Message-ID: <20181127072446.ylceky4fjx7ybe5u@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261514080.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261514080.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:16:28PM -0800, Hugh Dickins wrote:
> The term "freeze" is used in several ways in the kernel, and in mm it
> has the particular meaning of forcing page refcount temporarily to 0.
> freeze_page() is just too confusing a name for a function that unmaps
> a page: rename it unmap_page(), and rename unfreeze_page() remap_page().
> 
> Went to change the mention of freeze_page() added later in mm/rmap.c,
> but found it to be incorrect: ordinary page reclaim reaches there too;
> but the substance of the comment still seems correct, so edit it down.
> 
> Fixes: e9b61f19858a5 ("thp: reintroduce split_huge_page()")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: stable@vger.kernel.org # 4.8+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
