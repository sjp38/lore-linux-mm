Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE6DF6B46B2
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:02:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so23274836plk.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:02:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor3814852pgh.25.2018.11.27.00.02.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 00:02:41 -0800 (PST)
Date: Tue, 27 Nov 2018 11:02:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 10/10] mm/khugepaged: fix the xas_create_range() error
 path
Message-ID: <20181127080236.5skrst5kvphitoat@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261531200.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261531200.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:33:13PM -0800, Hugh Dickins wrote:
> collapse_shmem()'s xas_nomem() is very unlikely to fail, but it is
> rightly given a failure path, so move the whole xas_create_range() block
> up before __SetPageLocked(new_page): so that it does not need to remember
> to unlock_page(new_page).  Add the missing mem_cgroup_cancel_charge(),
> and set (currently unused) result to SCAN_FAIL rather than SCAN_SUCCEED.
> 
> Fixes: 77da9389b9d5 ("mm: Convert collapse_shmem to XArray")
> Signed-off-by: Hugh Dickins <hughd@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
