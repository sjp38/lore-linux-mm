Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9D09D6B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 09:35:16 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id ij19so618580vcb.38
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 06:35:16 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id bo9si7861272vcb.86.2014.06.02.06.35.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 06:35:15 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so5179684veb.34
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 06:35:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537F082F.50501@suse.cz>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
	<1400233673-11477-1-git-send-email-vbabka@suse.cz>
	<CAGa+x87-NRyK6kUiXNL_bRNEGm+DR6M3HPSLYEoq4t6Nrtnd_g@mail.gmail.com>
	<CAAQ0ZWQDVxAzZVm86ATXd1JGUVoLXj_Y5Ske7htxH_6a4GPKRg@mail.gmail.com>
	<537F082F.50501@suse.cz>
Date: Mon, 2 Jun 2014 10:35:15 -0300
Message-ID: <CAOMZO5BKaicq7NkoJO4vU5W3hiDike6kSdH+2eD=h0B5BsDjTg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, compaction: properly signal and act upon lock and
 need_sched() contention
From: Fabio Estevam <festevam@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Shawn Guo <shawn.guo@linaro.org>, Kevin Hilman <khilman@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Stephen Warren <swarren@wwwdotorg.org>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Olof Johansson <olof@lixom.net>, Greg Thelen <gthelen@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

Vlastimil,

On Fri, May 23, 2014 at 5:34 AM, Vlastimil Babka <vbabka@suse.cz> wrote:

> Really sorry, guys :/
>
> -----8<-----
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 23 May 2014 10:18:56 +0200
> Subject: mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention-fix2
>
> Step 1: Change function name and comment between v1 and v2 so that the return
>         value signals the opposite thing.
> Step 2: Change the call sites to reflect the opposite return value.
> Step 3: ???
> Step 4: Make a complete fool of yourself.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/compaction.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a525cd4..5175019 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -237,13 +237,13 @@ static inline bool compact_should_abort(struct compact_control *cc)
>         if (need_resched()) {
>                 if (cc->mode == MIGRATE_ASYNC) {
>                         cc->contended = true;
> -                       return false;
> +                       return true;
>                 }
>
>                 cond_resched();
>         }
>
> -       return true;
> +       return false;
>  }

This patch is still not in linux-next.

Could you please submit it formally?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
