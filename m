Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49E706B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 03:31:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c143so3484824wmd.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 00:31:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si1467241wrc.328.2017.03.15.00.31.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 00:31:48 -0700 (PDT)
Subject: Re: [PATCH v2 04/10] mm: make the try_to_munlock void function
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-5-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a3988c6c-88dc-f8f6-f4fc-1fa96a3bb313@suse.cz>
Date: Wed, 15 Mar 2017 08:31:45 +0100
MIME-Version: 1.0
In-Reply-To: <1489555493-14659-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 03/15/2017 06:24 AM, Minchan Kim wrote:
> try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> the page if the page is not pte-mapped THP which cannot be
> mlocked, either.
> 
> With that, __munlock_isolated_page can use PageMlocked to check
> whether try_to_munlock is successful or not without relying on
> try_to_munlock's retval. It helps to make try_to_unmap/try_to_unmap_one
> simple with upcoming patches.
> 
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
