Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E4BB3900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:44:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8FB873EE0C2
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:44:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A99745DEB3
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:44:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5202045DEB4
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:44:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AB7DE18002
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:44:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 946291DB803B
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:44:15 +0900 (JST)
Date: Tue, 13 Sep 2011 19:43:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 09/11] mm: collect LRU list heads into struct lruvec
Message-Id: <20110913194327.f4ee98f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-10-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-10-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:26 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Having a unified structure with a LRU list set for both global zones
> and per-memcg zones allows to keep that code simple which deals with
> LRU lists and does not care about the container itself.
> 
> Once the per-memcg LRU lists directly link struct pages, the isolation
> function and all other list manipulations are shared between the memcg
> case and the global LRU case.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
