Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 269188D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 18:48:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9E44D3EE0AE
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:48:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8567845DE50
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:48:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6303545DE4E
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:48:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 548B21DB803A
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:48:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 231F21DB8037
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:48:07 +0900 (JST)
Date: Fri, 4 Feb 2011 08:41:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/2] memcg: soft limit reclaim should end at limit not
 below
Message-Id: <20110204084157.80d3625d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203125453.GB2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
	<20110201000455.GB19534@cmpxchg.org>
	<20110131162448.e791f0ae.akpm@linux-foundation.org>
	<20110203125357.GA2286@cmpxchg.org>
	<20110203125453.GB2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 13:54:54 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Soft limit reclaim continues until the usage is below the current soft
> limit, but the documented semantics are actually that soft limit
> reclaim will push usage back until the soft limits are met again.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
