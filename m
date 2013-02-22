Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 54B566B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:44:17 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id s14so132695qeb.30
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 19:44:16 -0800 (PST)
Message-ID: <5126E987.7020809@gmail.com>
Date: Fri, 22 Feb 2013 11:44:07 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] ksm: responses to NUMA review
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/21/2013 04:17 PM, Hugh Dickins wrote:
> Here's a second KSM series, based on mmotm 2013-02-19-17-20: partly in
> response to Mel's review feedback, partly fixes to issues that I found
> myself in doing more review and testing.  None of the issues fixed are
> truly show-stoppers, though I would prefer them fixed sooner than later.

Do you have any ideas ksm support page cache and tmpfs?

>
> 1 ksm: add some comments
> 2 ksm: treat unstable nid like in stable tree
> 3 ksm: shrink 32-bit rmap_item back to 32 bytes
> 4 mm,ksm: FOLL_MIGRATION do migration_entry_wait
> 5 mm,ksm: swapoff might need to copy
> 6 mm: cleanup "swapcache" in do_swap_page
> 7 ksm: allocate roots when needed
>
>   Documentation/vm/ksm.txt |   16 +++-
>   include/linux/mm.h       |    1
>   mm/ksm.c                 |  137 +++++++++++++++++++++++--------------
>   mm/memory.c              |   38 +++++++---
>   mm/swapfile.c            |   15 +++-
>   5 files changed, 140 insertions(+), 67 deletions(-)
>
> Thanks,
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
