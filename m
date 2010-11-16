Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 668BE8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:49:49 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3nkhB004008
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:49:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB09245DE65
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:49:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7F645DE62
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:49:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 695ACE08004
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:49:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1201E1DB803E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:49:46 +0900 (JST)
Date: Tue, 16 Nov 2010 12:44:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 4/4] memcg: use native word page statistics counters
Message-Id: <20101116124414.98167f7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101107220353.964566018@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
	<20101107220353.964566018@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun,  7 Nov 2010 23:14:39 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The statistic counters are in units of pages, there is no reason to
> make them 64-bit wide on 32-bit machines.
> 
> Make them native words.  Since they are signed, this leaves 31 bit on
> 32-bit machines, which can represent roughly 8TB assuming a page size
> of 4k.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
