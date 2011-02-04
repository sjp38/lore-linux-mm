Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0B168D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 20:02:24 -0500 (EST)
Date: Fri, 4 Feb 2011 09:53:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [patch 3/5] memcg: fold __mem_cgroup_move_account into caller
Message-Id: <20110204095354.7332d8d4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110204090738.4eb6d766.kamezawa.hiroyu@jp.fujitsu.com>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-4-git-send-email-hannes@cmpxchg.org>
	<20110204090738.4eb6d766.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Fri, 4 Feb 2011 09:07:38 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu,  3 Feb 2011 15:26:04 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > It is one logical function, no need to have it split up.
> > 
> > Also, get rid of some checks from the inner function that ensured the
> > sanity of the outer function.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I think there was a reason to split them...but it seems I forget it..
> 
IIRC, it's me who split them up in commit 57f9fd7d.

But the purpose of the commit was cleanup move_parent() and move_account()
to use move_accout() in move_charge() later.
So, there was no technical reason why I split move_account() and __move_account().
It was just because I liked to make each functions do one thing: check validness
and actually move account.

Anyway, I don't have any objection to folding them. page_is_cgroup_locked()
can be removed by this change.

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
