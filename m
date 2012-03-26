Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A99C36B004D
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 21:13:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BACB13EE0BD
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:13:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A27AB45DE5D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:13:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 85B9845DE58
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:13:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7496B1DB8050
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:13:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CFD71DB804F
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:13:42 +0900 (JST)
Message-ID: <4F6FC263.1080609@jp.fujitsu.com>
Date: Mon, 26 Mar 2012 10:12:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg swap: mem_cgroup_move_swap_account never needs
 fixup
References: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

(2012/03/24 5:51), Hugh Dickins wrote:

> The need_fixup arg to mem_cgroup_move_swap_account() is always false,
> so just remove it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
