Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 05CAA8D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:04:00 -0400 (EDT)
Received: by iwg8 with SMTP id 8so8894695iwg.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 00:03:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110411170103.035A.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
	<20110411170103.035A.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 16:03:59 +0900
Message-ID: <BANLkTinvANUNE2CVcDCbkR+xNq0bq0RZCQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm, mem-hotplug: recalculate lowmem_reserve when
 memory hotplug occur
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Mon, Apr 11, 2011 at 5:00 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Currently, memory hotplug call setup_per_zone_wmarks() and
> calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve().
>
> It mean number of reserved pages aren't updated even if memory hot plug
> occur. This patch fixes it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
