Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 17B0C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:13:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F1DF83EE0BD
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:13:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DAE7645DE5A
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:13:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C258145DE59
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:13:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4EA7E08003
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:13:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F885E08002
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:13:44 +0900 (JST)
Date: Fri, 4 Feb 2011 09:07:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/5] memcg: fold __mem_cgroup_move_account into caller
Message-Id: <20110204090738.4eb6d766.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296743166-9412-4-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  3 Feb 2011 15:26:04 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> It is one logical function, no need to have it split up.
> 
> Also, get rid of some checks from the inner function that ensured the
> sanity of the outer function.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I think there was a reason to split them...but it seems I forget it..

The patch seems good.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
