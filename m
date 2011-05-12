Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E79BC6B0022
	for <linux-mm@kvack.org>; Thu, 12 May 2011 19:51:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 210223EE081
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:51:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ECEF845DE61
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:51:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3C8B45DD6D
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:51:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C6CC01DB803C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:51:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 924F61DB802C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:51:29 +0900 (JST)
Date: Fri, 13 May 2011 08:44:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc patch 1/6] memcg: remove unused retry signal from reclaim
Message-Id: <20110513084431.937d72e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 May 2011 16:53:53 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> If the memcg reclaim code detects the target memcg below its limit it
> exits and returns a guaranteed non-zero value so that the charge is
> retried.
> 
> Nowadays, the charge side checks the memcg limit itself and does not
> rely on this non-zero return value trick.
> 
> This patch removes it.  The reclaim code will now always return the
> true number of pages it reclaimed on its own.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
