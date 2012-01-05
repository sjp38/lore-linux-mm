Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 0F2B96B0062
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:32:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 85EC73EE0C8
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:32:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B66245DEEF
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:32:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BFF045DEEB
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:32:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EECD1DB8041
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:32:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB1DE1DB803B
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:32:37 +0900 (JST)
Date: Thu, 5 Jan 2012 15:31:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] memcg: replace mem and mem_cont stragglers
Message-Id: <20120105153124.e25af3f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112312328070.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
	<alpine.LSU.2.00.1112312328070.18500@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Sat, 31 Dec 2011 23:29:14 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Replace mem and mem_cont stragglers in memcontrol.c by memcg.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
