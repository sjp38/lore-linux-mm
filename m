Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3B13C8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:57:11 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A40B03EE0B3
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:57:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 85D3C45DE5E
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:57:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C62645DE56
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:57:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF02E08003
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:57:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23A551DB8046
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:57:09 +0900 (JST)
Date: Tue, 1 Feb 2011 08:51:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/3] memcg: never OOM when charging huge pages
Message-Id: <20110201085106.790e5f65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296482635-13421-4-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 Jan 2011 15:03:55 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Huge page coverage should obviously have less priority than the
> continued execution of a process.
> 
> Never kill a process when charging it a huge page fails.  Instead,
> give up after the first failed reclaim attempt and fall back to
> regular pages.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
