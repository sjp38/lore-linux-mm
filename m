Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 15331900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:35:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DAF693EE0C0
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:34:57 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C36DE45DE81
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4F2845DE7A
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 952E61DB802C
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:34:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59F7C1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:34:57 +0900 (JST)
Date: Tue, 13 Sep 2011 19:34:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 06/11] mm: memcg: remove optimization of keeping the
 root_mem_cgroup LRU lists empty
Message-Id: <20110913193407.16c8c5bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-7-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-7-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:23 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> root_mem_cgroup, lacking a configurable limit, was never subject to
> limit reclaim, so the pages charged to it could be kept off its LRU
> lists.  They would be found on the global per-zone LRU lists upon
> physical memory pressure and it made sense to avoid uselessly linking
> them to both lists.
> 
> The global per-zone LRU lists are about to go away on memcg-enabled
> kernels, with all pages being exclusively linked to their respective
> per-memcg LRU lists.  As a result, pages of the root_mem_cgroup must
> also be linked to its LRU lists again.
> 
> The overhead is temporary until the double-LRU scheme is going away
> completely.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
