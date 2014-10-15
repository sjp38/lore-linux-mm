Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B06236B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:07:55 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hi2so13945791wib.15
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 13:07:54 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id i3si26789867wjw.74.2014.10.15.13.07.53
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 13:07:54 -0700 (PDT)
Date: Wed, 15 Oct 2014 23:07:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] mm: verify compound order when freeing a page
Message-ID: <20141015200745.GB17066@node.dhcp.inet.fi>
References: <1413400805-15547-1-git-send-email-yuzhao@google.com>
 <1413400805-15547-2-git-send-email-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413400805-15547-2-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, Oct 15, 2014 at 12:20:05PM -0700, Yu Zhao wrote:
> This allows us to catch the bug fixed in the previous patch
> (mm: free compound page with correct order).
> 
> Here we also verify whether a page is tail page or not -- tail
> pages are supposed to be freed along with their head, not by
> themselves.
> 
> Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I didn't give this tag. It's okay in this case, but please do not assume
that you've got Reviewed-by, unless the person said it explicitly.

> Signed-off-by: Yu Zhao <yuzhao@google.com>

Your Singed-off-by should come first.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
