Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0F26B006C
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:24:36 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id a1so20930944wgh.12
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:24:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ew8si12519529wic.29.2015.02.22.05.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 05:24:35 -0800 (PST)
Date: Sun, 22 Feb 2015 08:24:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 3/4] mm: refactor do_wp_page, extract the page copy
 flow
Message-ID: <20150222132431.GC5324@phnom.home.cmpxchg.org>
References: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
 <1424609241-20106-4-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424609241-20106-4-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Sun, Feb 22, 2015 at 02:47:20PM +0200, Shachar Raindel wrote:
> In some cases, do_wp_page had to copy the page suffering a write fault
> to a new location. If the function logic decided that to do this, it
> was done by jumping with a "goto" operation to the relevant code
> block. This made the code really hard to understand. It is also
> against the kernel coding style guidelines.
> 
> This patch extracts the page copy and page table update logic to a
> separate function. It also clean up the naming, from "gotten" to
> "wp_page_copy", and adds few comments.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Haggai Eran <haggaie@mellanox.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Feiner <pfeiner@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michel Lespinasse <walken@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
