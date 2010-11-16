Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6976A8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:44:50 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3im9m020025
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:44:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0633645DE5F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:44:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A9CBA45DE56
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:44:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 696BEE18003
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:44:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 192A5E08008
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:44:47 +0900 (JST)
Date: Tue, 16 Nov 2010 12:39:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/4] memcg: catch negative per-cpu sums in dirty info
Message-Id: <20101116123912.95d8605f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101107220353.414283590@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
	<20101107220353.414283590@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun,  7 Nov 2010 23:14:37 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Folding the per-cpu counters can yield a negative value in case of
> accounting races between CPUs.
> 
> When collecting the dirty info, the code would read those sums into an
> unsigned variable and then check for it being negative, which can not
> work.
> 
> Instead, fold the counters into a signed local variable, make the
> check, and only then assign it.
> 
> This way, the function signals correctly when there are insane values
> instead of leaking them out to the caller.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
