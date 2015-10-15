Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EEE356B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 05:09:28 -0400 (EDT)
Received: by payp3 with SMTP id p3so34347500pay.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:09:28 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id fm3si20089075pab.106.2015.10.15.02.09.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Oct 2015 02:09:28 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC v2 0/3] zsmalloc: make its pages can be migrated
Date: Thu, 15 Oct 2015 17:08:59 +0800
Message-ID: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
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

According to the review for the prev version [1], I got that I should
not increase the size of struct page.
So I update it in new version.

And I also add check for CONFIG_MIGRATION to make function just work
when CONFIG_MIGRATION is open.

Hui Zhu (3):
migrate: new struct migration and add it to struct page
zsmalloc: mark its page "PageMigration"
zram: make create "__GFP_MOVABLE" pool

 drivers/block/zram/zram_drv.c |    6 
 include/linux/migrate.h       |   43 ++
 include/linux/mm_types.h      |    3 
 mm/compaction.c               |    8 
 mm/migrate.c                  |   17 -
 mm/vmscan.c                   |    2 
 mm/zsmalloc.c                 |  605 +++++++++++++++++++++++++++++++++++++++---
 7 files changed, 639 insertions(+), 45 deletions(-)

[1] http://comments.gmane.org/gmane.linux.kernel.mm/139724

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
