Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 588D26B0062
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:35:53 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E0B933EE0AE
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:35:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C79AD45DE68
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:35:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AEEE345DE4D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:35:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1B3A1DB803E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:35:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52A1B1DB8038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:35:51 +0900 (JST)
Date: Thu, 5 Jan 2012 15:34:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] memcg: enum lru_list lru
Message-Id: <20120105153439.42cca5d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112312330460.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
	<alpine.LSU.2.00.1112312330460.18500@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Sat, 31 Dec 2011 23:31:53 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Mostly we use "enum lru_list lru": change those few "l"s to "lru"s.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
