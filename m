Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6486E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:50:34 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 298FF3EE0BD
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:50:21 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09DAF45DE61
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:50:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E4CCF45DD74
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:50:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D67201DB803C
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:50:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0BE81DB8038
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:50:20 +0900 (JST)
Date: Thu, 10 Feb 2011 08:44:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: remove memcg->reclaim_param_lock
Message-Id: <20110210084411.d2523c73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297248362-23579-1-git-send-email-hannes@cmpxchg.org>
References: <1297248362-23579-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 11:46:02 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The reclaim_param_lock is only taken around single reads and writes to
> integer variables and is thus superfluous.  Drop it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
