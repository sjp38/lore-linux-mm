Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 90DE28D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 23:08:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG48AO5012074
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Nov 2010 13:08:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2856745DE6F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F124045DE6E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B07E1DB8037
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F02E71DB804B
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:08 +0900 (JST)
Date: Tue, 16 Nov 2010 13:02:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: fix unit mismatch in memcg oom limit calculation
Message-Id: <20101116130240.92986f01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101109110521.GS23393@cmpxchg.org>
References: <20101109110521.GS23393@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010 12:05:21 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Adding the number of swap pages to the byte limit of a memory control
> group makes no sense.  Convert the pages to bytes before adding them.
> 
> The only user of this code is the OOM killer, and the way it is used
> means that the error results in a higher OOM badness value.  Since the
> cgroup limit is the same for all tasks in the cgroup, the error should
> have no practical impact at the moment.
> 
> But let's not wait for future or changing users to trip over it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
