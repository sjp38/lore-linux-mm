Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3C898D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:43:24 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3hM2q019567
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:43:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06A2245DE4F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:43:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D513045DE55
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:43:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9996EE38002
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:43:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22BC6E08001
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:43:18 +0900 (JST)
Date: Tue, 16 Nov 2010 12:37:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/4] memcg: use native word to represent dirtyable pages
Message-Id: <20101116123728.295d3095.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101107220353.115646194@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
	<20101107220353.115646194@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun,  7 Nov 2010 23:14:36 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The memory cgroup dirty info calculation currently uses a signed
> 64-bit type to represent the amount of dirtyable memory in pages.
> 
> This can instead be changed to an unsigned word, which will allow the
> formula to function correctly with up to 160G of LRU pages on a 32-bit
> system, assuming 4k pages.  That should be plenty even when taking
> racy folding of the per-cpu counters into account.
> 
> This fixes a compilation error on 32-bit systems as this code tries to
> do 64-bit division.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: Dave Young <hidave.darkstar@gmail.com>


Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I couldn't read email because of vacation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
