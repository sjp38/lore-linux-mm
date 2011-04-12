Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45AC08D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 05:24:10 -0400 (EDT)
Received: by iwg8 with SMTP id 8so9030525iwg.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:24:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110411170134.035E.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
	<20110411170134.035E.A69D9226@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 18:24:08 +0900
Message-ID: <BANLkTi=fEejkrPdX27bFi1x+dHpOSGxQaQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when
 memory hotplug occur
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Hi, KOSAKI

On Mon, Apr 11, 2011 at 5:01 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Currently, cpu hotplug updates pcp->stat_threashold, but memory
> hotplug doesn't. there is no reason.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <cl@linux.com>

I can think it makes sense so I don't oppose the patch merging.
But as you know I am very keen on the description.

What is the problem if hotplug doesn't do it?
I means the patch solves what's problem?

Please write down fully for better description.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
