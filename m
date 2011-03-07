Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A42978D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:54:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 267313EE0BD
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:54:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0974045DE59
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:54:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E424E45DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:54:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD219E18001
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:54:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97C36E08005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:54:52 +0900 (JST)
Date: Mon, 7 Mar 2011 18:48:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2 11/24] sys_swapon: do only cleanup in the cleanup
 blocks
Message-Id: <20110307184829.24192fb1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1299343345-3984-12-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-12-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat,  5 Mar 2011 13:42:12 -0300
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> The only way error is 0 in the cleanup blocks is when the function is
> returning successfully. In this case, the cleanup blocks were setting
> S_SWAPFILE in the S_ISREG case. But this is not a cleanup.
> 
> Move the setting of S_SWAPFILE to just before the "goto out;" to make
> this more clear. At this point, we do not need to test for inode because
> it will never be NULL.
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
