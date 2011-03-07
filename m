Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84D878D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 05:05:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A88923EE0C0
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:05:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9141545DE51
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:05:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 763C845DE4F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:05:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6762D1DB8041
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:05:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EC2B1DB803B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:05:54 +0900 (JST)
Date: Mon, 7 Mar 2011 18:59:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2 18/24] sys_swapon: call swap_cgroup_swapon earlier
Message-Id: <20110307185934.506df651.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299343345-3984-19-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-19-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat,  5 Mar 2011 13:42:19 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> The call to swap_cgroup_swapon is in the middle of loading the swap map
> and extents. As it only does memory allocation and does not depend on
> the swapfile layout (map/extents), it can be called earlier (or later).
> 
> Move it to just after the allocation of swap_map, since it is
> conceptually similar (allocates a map).
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
