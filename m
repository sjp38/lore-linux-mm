Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D28FB6B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 04:09:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BE3E23EE0B5
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:09:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D6D72AED5E
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:09:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EE962E68C3
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:09:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DBA3EF8004
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:09:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D220EF8007
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:09:21 +0900 (JST)
Date: Mon, 16 May 2011 17:02:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: implement swap token trace
Message-Id: <20110516170241.d918031e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4DCD18C4.1000902@jp.fujitsu.com>
References: <4DCD1824.1060801@jp.fujitsu.com>
	<4DCD18C4.1000902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com

On Fri, 13 May 2011 20:40:52 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> This is useful for observing swap token activity.
> 
> example output:
> 
>              zsh-1845  [000]   598.962716: update_swap_token_priority:
> mm=ffff88015eaf7700 old_prio=1 new_prio=0
>           memtoy-1830  [001]   602.033900: update_swap_token_priority:
> mm=ffff880037a45880 old_prio=947 new_prio=949
>           memtoy-1830  [000]   602.041509: update_swap_token_priority:
> mm=ffff880037a45880 old_prio=949 new_prio=951
>           memtoy-1830  [000]   602.051959: update_swap_token_priority:
> mm=ffff880037a45880 old_prio=951 new_prio=953
>           memtoy-1830  [000]   602.052188: update_swap_token_priority:
> mm=ffff880037a45880 old_prio=953 new_prio=955
>           memtoy-1830  [001]   602.427184: put_swap_token:
> token_mm=ffff880037a45880
>              zsh-1789  [000]   602.427281: replace_swap_token:
> old_token_mm=          (null) old_prio=0 new_token_mm=ffff88015eaf7018
> new_prio=2
>              zsh-1789  [001]   602.433456: update_swap_token_priority:
> mm=ffff88015eaf7018 old_prio=2 new_prio=4
>              zsh-1789  [000]   602.437613: update_swap_token_priority:
> mm=ffff88015eaf7018 old_prio=4 new_prio=6
>              zsh-1789  [000]   602.443924: update_swap_token_priority:
> mm=ffff88015eaf7018 old_prio=6 new_prio=8
>              zsh-1789  [000]   602.451873: update_swap_token_priority:
> mm=ffff88015eaf7018 old_prio=8 new_prio=10
>              zsh-1789  [001]   602.462639: update_swap_token_priority:
> mm=ffff88015eaf7018 old_prio=10 new_prio=12
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
