Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 886D96B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:06:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 797873EE0AE
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:06:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 610FE45DE55
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:06:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AC6445DE54
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:06:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AFE7E08001
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:06:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8285E08002
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:06:52 +0900 (JST)
Date: Tue, 28 Feb 2012 09:05:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 01/21] memcg: unify inactive_ratio calculation
Message-Id: <20120228090526.201b4e9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135141.12988.12236.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135141.12988.12236.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:51:41 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch removes precalculated zone->inactive_ratio.
> Now it always calculated in inactive_anon_is_low() from current lru sizes.
> After that we can merge memcg and non-memcg cases and drop duplicated code.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

seems good to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
