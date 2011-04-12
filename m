Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3ED8D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:28:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 634FF3EE0B5
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:28:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BBD745DE93
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:28:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3464D45DE90
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:28:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 28619E08003
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:28:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9D14E08001
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:28:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm, mem-hotplug: fix section mismatch. setup_per_zone_inactive_ratio() should be __meminit.
In-Reply-To: <BANLkTimPB5e_A3AxS_7kuJmqciRciCm2Sw@mail.gmail.com>
References: <20110411170033.0356.A69D9226@jp.fujitsu.com> <BANLkTimPB5e_A3AxS_7kuJmqciRciCm2Sw@mail.gmail.com>
Message-Id: <20110412192751.B52B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 12 Apr 2011 19:28:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Hi

> On Mon, Apr 11, 2011 at 5:00 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Commit bce7394a3e (page-allocator: reset wmark_min and inactive ratio of
> > zone when hotplug happens) introduced invalid section references.
> > Now, setup_per_zone_inactive_ratio() is marked __init and then it can't
> > be referenced from memory hotplug code.
> >
> > Then, this patch marks it as __meminit and also marks caller as __ref.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Just a nitpick.
> 
> As below comment of __ref said, It would be better to add _why_ such
> as memory_hotplug.c.
> 
> "so optimally document why the __ref is needed and why it's OK"

Hmm...
All of memory_hotplug.c function can call __meminit function. It's
definition of __meminit.

We can put the same comment to every function in memory_hotplug.c. 
like hotadd_newpgdat().

/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
{
(snip)
}

But it has zero information. ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
