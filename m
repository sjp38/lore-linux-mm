Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 535C76B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:00:03 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1590119ghr.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 05:00:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
References: <4FD97718.6060008@kernel.org> <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 14 Jun 2012 07:59:42 -0400
Message-ID: <CAHGf_=p0E9_iXuDS_RNCGp2KPiU+=BO5AB6ZxqnSE57mNiyQGw@mail.gmail.com>
Subject: Re: [PATCH] trivial, memory hotplug: add kswapd_is_running() for
 better readability
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Thu, Jun 14, 2012 at 4:49 AM, Jiang Liu <jiang.liu@huawei.com> wrote:
> Add kswapd_is_running() to check whether the kswapd worker thread is already
> running before calling kswapd_run() when onlining memory pages.
>
> It's based on a draft version from Minchan Kim <minchan@kernel.org>.
>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
