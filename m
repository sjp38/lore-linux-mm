Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DEC6D8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:34:41 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 24E303EE0AE
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:34:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06AA045DE51
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:34:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D3845DE4F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:34:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A911DB803B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:34:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1E231DB802F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:34:38 +0900 (JST)
Date: Mon, 7 Mar 2011 18:28:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2 04/24] sys_swapon: separate swap_info allocation
Message-Id: <20110307182815.a3570cfc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299343345-3984-5-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-5-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat,  5 Mar 2011 13:42:05 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> Move the swap_info allocation to its own function. Only code movement,
> no functional changes.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, I like "allocation returns NULL at failure" if the only error value
is -ENOMEM...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
