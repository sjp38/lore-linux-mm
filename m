Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A23D16B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:42:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2F3DB3EE0B5
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:42:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1752A45DE4E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:42:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F25D245DE4D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:42:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C251DB803B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:42:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A2B741DB8037
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:42:37 +0900 (JST)
Date: Tue, 28 Feb 2012 09:41:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 10/21] mm: kill struct mem_cgroup_zone
Message-Id: <20120228094109.e1b96c22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135229.12988.66375.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135229.12988.66375.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:29 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> struct mem_cgroup_zone always points to one lruvec, either root zone->lruvec or
> to some from memcg. So this fancy pointer can be replaced with direct pointer to
> struct lruvec, because all required infromation already collected on lruvec.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
