Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1616B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:01:23 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 821AB3EE0BC
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:01:20 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68CBB45DE57
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:01:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EDAA45DE52
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:01:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F9CEE08007
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:01:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F200FE08003
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:01:19 +0900 (JST)
Date: Thu, 24 Nov 2011 09:00:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/8] mm: memcg: clean up fault accounting
Message-Id: <20111124090015.18edb1dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:26 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> The fault accounting functions have a single, memcg-internal user, so
> they don't need to be global.  In fact, their one-line bodies can be
> directly folded into the caller.  And since faults happen one at a
> time, use this_cpu_inc() directly instead of this_cpu_add(foo, 1).
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'm not sure why Ying Han used this style.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
