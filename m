Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 24C198D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:47:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG3lSbe003941
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 12:47:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EFCD45DE4F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:47:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D18C45DE4D
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:47:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D9E1DB8037
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:47:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA0371DB803B
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:47:24 +0900 (JST)
Date: Tue, 16 Nov 2010 12:41:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/4] memcg: break out event counters from other stats
Message-Id: <20101116124151.4830f685.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101107220353.684449249@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
	<20101107220353.684449249@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun,  7 Nov 2010 23:14:38 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> For increasing and decreasing per-cpu cgroup usage counters it makes
> sense to use signed types, as single per-cpu values might go negative
> during updates.  But this is not the case for only-ever-increasing
> event counters.
> 
> All the counters have been signed 64-bit so far, which was enough to
> count events even with the sign bit wasted.
> 
> The next patch narrows the usage counters type (on 32-bit CPUs, that
> is), though, so break out the event counters and make them unsigned
> words as they should have been from the start.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
