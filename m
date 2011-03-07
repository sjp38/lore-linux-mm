Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7C64B8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:58:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 27C343EE0C0
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:58:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D7445DD74
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:58:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF89245DE55
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:58:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1AEEE38003
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:58:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80F221DB803A
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:58:42 +0900 (JST)
Date: Mon, 7 Mar 2011 18:52:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2 12/24] sys_swapon: use a single error label
Message-Id: <20110307185220.e3abc708.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299343345-3984-13-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-13-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat,  5 Mar 2011 13:42:13 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> sys_swapon currently has two error labels, bad_swap and bad_swap_2.
> bad_swap does the same as bad_swap_2 plus destroy_swap_extents() and
> swap_cgroup_swapoff(); both are noops in the places where bad_swap_2 is
> jumped to. With a single extra test for inode (matching the one in the
> S_ISREG case below), all the error paths in the function can go to
> bad_swap.
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
