Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5DE0828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 22:31:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so484986700pfx.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 19:31:48 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r85si1373885pfb.223.2016.07.05.19.31.47
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 19:31:48 -0700 (PDT)
Date: Wed, 6 Jul 2016 11:32:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 1/8] mm/zsmalloc: modify zs compact trace interface
Message-ID: <20160706023232.GB13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

Hi Ganesh,

On Mon, Jul 04, 2016 at 02:49:52PM +0800, Ganesh Mahendran wrote:
> This patch changes trace_zsmalloc_compact_start[end] to
> trace_zs_compact_start[end] to keep function naming consistent
> with others in zsmalloc
> 
> Also this patch remove pages_total_compacted information which
> may not really needed.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Once we decide to add event trace, I prefer getting more detailed
information which is hard to get it via /sys/block/zram/.
So, we can add trace __zs_compact as well as zs_compact with
some changes.

IOW,

zs_compact
        trace_zs_compact_start(pool->name)
        __zs_compact
                trace_zs_compact(class, scanned_obj, freed_pages)
        trace_zs_compact_end(pool->name)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
