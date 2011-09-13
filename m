Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 90A14900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:51:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7836A3EE0C0
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:51:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F89545DEB4
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:51:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4740545DE7E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:51:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 378A81DB803F
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:51:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0257A1DB803C
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:51:19 +0900 (JST)
Date: Tue, 13 Sep 2011 19:50:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 11/11] mm: memcg: remove unused node/section info from
 pc->flags
Message-Id: <20110913195031.5fa2a3c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-12-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-12-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:28 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> To find the page corresponding to a certain page_cgroup, the pc->flags
> encoded the node or section ID with the base array to compare the pc
> pointer to.
> 
> Now that the per-memory cgroup LRU lists link page descriptors
> directly, there is no longer any code that knows the page_cgroup but
> not the page.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Ah, ok. remove init code and use zalloc()

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
