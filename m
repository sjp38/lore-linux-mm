Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 1D5D56B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 20:27:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 293D03EE081
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:27:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1219345DE56
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:27:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF88045DE55
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:27:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3619E08001
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:27:45 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CF2F1DB8042
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:27:45 +0900 (JST)
Date: Thu, 9 Feb 2012 10:26:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
Message-Id: <20120209102619.6058571d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328559569-10783-1-git-send-email-yinghan@google.com>
References: <1328559569-10783-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Mon,  6 Feb 2012 12:19:29 -0800
Ying Han <yinghan@google.com> wrote:

> In v3.3-rc1, the global LRU has been removed with commit
> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.
> 
> I left the swap session to someone who has better understanding of
> 'memory+swap'.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
