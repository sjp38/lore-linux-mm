Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EABAB900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:47:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 75D973EE0B6
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:47:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B6E345DE81
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 30BCB45DE68
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A9431DB8041
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:47:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D37D81DB803C
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:47:49 +0900 (JST)
Date: Tue, 13 Sep 2011 19:47:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 10/11] mm: make per-memcg LRU lists exclusive
Message-Id: <20110913194704.783d0547.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-11-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-11-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:27 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Now that all code that operated on global per-zone LRU lists is
> converted to operate on per-memory cgroup LRU lists instead, there is
> no reason to keep the double-LRU scheme around any longer.
> 
> The pc->lru member is removed and page->lru is linked directly to the
> per-memory cgroup LRU lists, which removes two pointers from a
> descriptor that exists for every page frame in the system.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
