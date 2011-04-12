Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2748D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:18:37 -0400 (EDT)
Received: by iyh42 with SMTP id 42so889765iyh.14
        for <linux-mm@kvack.org>; Mon, 11 Apr 2011 23:18:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110411170033.0356.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
	<20110411170033.0356.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 15:18:35 +0900
Message-ID: <BANLkTimPB5e_A3AxS_7kuJmqciRciCm2Sw@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm, mem-hotplug: fix section mismatch.
 setup_per_zone_inactive_ratio() should be __meminit.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Mon, Apr 11, 2011 at 5:00 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Commit bce7394a3e (page-allocator: reset wmark_min and inactive ratio of
> zone when hotplug happens) introduced invalid section references.
> Now, setup_per_zone_inactive_ratio() is marked __init and then it can't
> be referenced from memory hotplug code.
>
> Then, this patch marks it as __meminit and also marks caller as __ref.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Just a nitpick.

As below comment of __ref said, It would be better to add _why_ such
as memory_hotplug.c.

"so optimally document why the __ref is needed and why it's OK"

Anyway,
Thanks, KOSAKI.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
