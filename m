Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D48656B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 03:02:32 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so46140699pac.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 00:02:32 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id a4si64091712pas.197.2015.10.08.00.02.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 00:02:32 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so45954800pab.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 00:02:31 -0700 (PDT)
Date: Thu, 8 Oct 2015 16:03:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC 0/3] zsmalloc: make its pages movable
Message-ID: <20151008070320.GA447@swordfish>
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (10/08/15 14:35), Hui Zhu wrote:
> 
> As the discussion in the list, the zsmalloc introduce some problems
> around pages because its pages are unmovable.
> 
> These patches introduced page move function to zsmalloc.  And they also
> add interface to struct page.
> 

Hi,

have you seen
 http://lkml.iu.edu/hypermail/linux/kernel/1507.0/03233.html
 http://lkml.iu.edu/hypermail/linux/kernel/1508.1/00696.html

?


	-ss

> Hui Zhu (3):
> page: add new flags "PG_movable" and add interfaces to control these pages
> zsmalloc: mark its page "PG_movable"
> zram: make create "__GFP_MOVABLE" pool
>  drivers/block/zram/zram_drv.c |    4 
>  include/linux/mm_types.h      |   11 +
>  include/linux/page-flags.h    |    3 
>  mm/compaction.c               |    6 
>  mm/debug.c                    |    1 
>  mm/migrate.c                  |   17 +
>  mm/vmscan.c                   |    2 
>  mm/zsmalloc.c                 |  409 ++++++++++++++++++++++++++++++++++++++++--
>  8 files changed, 428 insertions(+), 25 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
