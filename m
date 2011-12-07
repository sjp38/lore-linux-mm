Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4E03C6B008C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 21:17:01 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E850E3EE0B5
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:16:59 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CECF545DE6D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:16:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A3A3845DE6B
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:16:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9116E1DB8056
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:16:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46CC61DB8052
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 11:16:59 +0900 (JST)
Date: Wed, 7 Dec 2011 11:15:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] memcg: revert current soft limit reclaim
 implementation
Message-Id: <20111207111550.6c23c5e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323215999-29164-3-git-send-email-yinghan@google.com>
References: <1323215999-29164-1-git-send-email-yinghan@google.com>
	<1323215999-29164-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Tue,  6 Dec 2011 15:59:58 -0800
Ying Han <yinghan@google.com> wrote:

> This patch reverts all the existing softlimit reclaim implementations, and
> should be merged together with previous patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

I'm ok with this. Because of changes in vmscan.c, it's not valuable to keep per-zone
softlimit statistics. All memcg under tree will be visited anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
