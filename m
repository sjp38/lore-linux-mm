Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 36A576B002C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 20:24:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 725CB3EE081
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:24:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B39D45DE4D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:24:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 430DB45DD74
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:24:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3520F1DB8038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:24:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E48171DB802C
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:24:10 +0900 (JST)
Date: Tue, 28 Feb 2012 10:22:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 17/21] mm: handle lruvec relock in memory controller
Message-Id: <20120228102243.a353f871.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135310.12988.46867.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135310.12988.46867.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:53:10 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Carefully relock lruvec lru lock at page memory cgroup change.
> 
> * In free_pn_rcu() wait for lruvec lock release.
>   Locking primitives keep lruvec pointer after successful lock held.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
