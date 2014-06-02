Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5CADD6B0036
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 16:09:12 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so3889388igb.5
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 13:09:12 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id dq1si27145889icb.23.2014.06.02.13.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 13:09:11 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so3884418igd.14
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 13:09:11 -0700 (PDT)
Date: Mon, 2 Jun 2014 13:09:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] mm, compaction: properly signal and act upon lock
 and need_sched() contention - fix
In-Reply-To: <538C8B45.6070803@suse.cz>
Message-ID: <alpine.DEB.2.02.1406021308510.13589@chino.kir.corp.google.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com> <CAAQ0ZWQDVxAzZVm86ATXd1JGUVoLXj_Y5Ske7htxH_6a4GPKRg@mail.gmail.com>
 <537F082F.50501@suse.cz> <CAOMZO5BKaicq7NkoJO4vU5W3hiDike6kSdH+2eD=h0B5BsDjTg@mail.gmail.com> <538C8B45.6070803@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Fabio Estevam <festevam@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shawn Guo <shawn.guo@linaro.org>, Kevin Hilman <khilman@linaro.org>, Rik van Riel <riel@redhat.com>, Stephen Warren <swarren@wwwdotorg.org>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Olof Johansson <olof@lixom.net>, Greg Thelen <gthelen@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On Mon, 2 Jun 2014, Vlastimil Babka wrote:

> compact_should_abort() returns true instead of false and vice versa
> due to changes between v1 and v2 of the patch. This makes both async
> and sync compaction abort with high probability, and has been reported
> to cause e.g. soft lockups on some ARM boards, or drivers calling
> dma_alloc_coherent() fail to probe with CMA enabled on different boards.
> 
> This patch fixes the return value to match comments and callers expecations.
> 
> Reported-and-tested-by: Kevin Hilman <khilman@linaro.org>
> Reported-and-tested-by: Shawn Guo <shawn.guo@linaro.org>
> Tested-by: Stephen Warren <swarren@nvidia.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
