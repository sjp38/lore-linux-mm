Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 109B68D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:45:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DBDE53EE0BD
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:45:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDAB545DE95
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:45:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3FAB45DE74
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:45:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FA39E0800D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:45:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13492E08005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:45:12 +0900 (JST)
Date: Tue, 12 Apr 2011 15:38:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm, mem-hotplug: fix section mismatch.
 setup_per_zone_inactive_ratio() should be __meminit.
Message-Id: <20110412153837.ea0f3f04.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110411170033.0356.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
	<20110411170033.0356.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

On Mon, 11 Apr 2011 17:00:08 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Commit bce7394a3e (page-allocator: reset wmark_min and inactive ratio of
> zone when hotplug happens) introduced invalid section references.
> Now, setup_per_zone_inactive_ratio() is marked __init and then it can't
> be referenced from memory hotplug code.
> 
> Then, this patch marks it as __meminit and also marks caller as __ref.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
