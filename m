Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5786B0070
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:28:38 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so11473678wiw.1
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:28:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jj6si12510088wid.41.2015.02.22.05.28.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 05:28:36 -0800 (PST)
Date: Sun, 22 Feb 2015 08:28:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 4/4] mm: Refactor do_wp_page handling of shared vma
 into a function
Message-ID: <20150222132832.GD5324@phnom.home.cmpxchg.org>
References: <1424609241-20106-1-git-send-email-raindel@mellanox.com>
 <1424609241-20106-5-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424609241-20106-5-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Sun, Feb 22, 2015 at 02:47:21PM +0200, Shachar Raindel wrote:
> The do_wp_page function is extremely long. Extract the logic for
> handling a page belonging to a shared vma into a function of its own.
> 
> This helps the readability of the code, without doing any functional
> change in it.
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
