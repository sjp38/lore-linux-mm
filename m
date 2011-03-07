Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C27C08D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 05:13:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 10D073EE0C1
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:13:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E303A45DE59
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:12:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C93F145DE54
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:12:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9666E38002
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:12:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 86C6A1DB8048
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 19:12:59 +0900 (JST)
Date: Mon, 7 Mar 2011 19:06:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2 23/24] sys_swapoff: change order to match sys_swapon
Message-Id: <20110307190633.04f1a598.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299343345-3984-24-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-24-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat,  5 Mar 2011 13:42:24 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> The block in sys_swapon which does the final adjustments to the
> swap_info_struct and to swap_list is the same as the block which
> re-inserts it again at sys_swapoff on failure of try_to_unuse(), except
> for the order of the operations within the lock. Since the order should
> not matter, arbitrarily change sys_swapoff to match sys_swapon, in
> preparation to making both share the same code.
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
