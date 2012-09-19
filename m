Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 7A0DB6B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 14:07:52 -0400 (EDT)
Received: by obhx4 with SMTP id x4so1644936obh.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 11:07:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com> <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 19 Sep 2012 14:07:29 -0400
Message-ID: <CAHGf_=rhVpJ7nAT_bd47th5mQno6OqP63G2fLM-XtCaBr+Mv-g@mail.gmail.com>
Subject: Re: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Fri, Sep 14, 2012 at 10:29 AM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
> page->private gets re-used in __free_one_page() to store page order
> (so trace_mm_page_pcpu_drain() may print order instead of migratetype)
> thus migratetype value must be cached locally.
>
> Fixes regression introduced in a701623 ("mm: fix migratetype bug
> which slowed swapping").
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
