Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C44556B026E
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 08:41:18 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id x93so26735361ybh.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 05:41:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o189si4418332ywd.408.2016.09.07.05.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 05:41:15 -0700 (PDT)
Date: Wed, 7 Sep 2016 14:41:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, thp: fix leaking mapped pte in
 __collapse_huge_page_swapin()
Message-ID: <20160907124106.5ucjmkuj6c3olpkf@redhat.com>
References: <1472820276-7831-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472820276-7831-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Fri, Sep 02, 2016 at 03:44:36PM +0300, Ebru Akagunduz wrote:
> Currently, khugepaged does not let swapin, if there is no
> enough young pages in a THP. The problem is when a THP does
> not have enough young page, khugepaged leaks mapped ptes.
> 
> This patch prohibits leaking mapped ptes.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/khugepaged.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
