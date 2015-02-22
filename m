Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 60C8F6B006C
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:19:14 -0500 (EST)
Received: by wevl61 with SMTP id l61so9239200wev.2
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:19:14 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hq7si12508363wib.19.2015.02.22.05.19.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 05:19:13 -0800 (PST)
Date: Sun, 22 Feb 2015 08:19:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 2/4] mm: Refactor do_wp_page - rewrite the unlock flow
Message-ID: <20150222131909.GB5324@phnom.home.cmpxchg.org>
References: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
 <1424609241-20106-3-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424609241-20106-3-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Sun, Feb 22, 2015 at 02:47:19PM +0200, Shachar Raindel wrote:
> When do_wp_page is ending, in several cases it needs to unlock the
> pages and ptls it was accessing.
> 
> Currently, this logic was "called" by using a goto jump. This makes
> following the control flow of the function harder. Readability was
> further hampered by the unlock case containing large amount of logic
> needed only in one of the 3 cases.
> 
> Using goto for cleanup is generally allowed. However, moving the
> trivial unlocking flows to the relevant call sites allow deeper
> refactoring in the next patch.
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
