Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DA9E26B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 02:36:04 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so45289260pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:36:04 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id fe1si63916482pab.169.2015.10.07.23.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 23:36:04 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 0/3] zsmalloc: make its pages movable
Date: Thu, 8 Oct 2015 14:35:49 +0800
Message-ID: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg
 Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

As the discussion in the list, the zsmalloc introduce some problems
around pages because its pages are unmovable.

These patches introduced page move function to zsmalloc.  And they also
add interface to struct page.

Hui Zhu (3):
page: add new flags "PG_movable" and add interfaces to control these pages
zsmalloc: mark its page "PG_movable"
zram: make create "__GFP_MOVABLE" pool
 drivers/block/zram/zram_drv.c |    4 
 include/linux/mm_types.h      |   11 +
 include/linux/page-flags.h    |    3 
 mm/compaction.c               |    6 
 mm/debug.c                    |    1 
 mm/migrate.c                  |   17 +
 mm/vmscan.c                   |    2 
 mm/zsmalloc.c                 |  409 ++++++++++++++++++++++++++++++++++++++++--
 8 files changed, 428 insertions(+), 25 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
