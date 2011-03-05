Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D18D28D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 14:07:56 -0500 (EST)
Date: Sat, 5 Mar 2011 20:07:20 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCHv2 01/24] sys_swapon: use vzalloc instead of
 vmalloc/memset
In-Reply-To: <1299343345-3984-2-git-send-email-cesarb@cesarb.net>
Message-ID: <alpine.LNX.2.00.1103052006530.32044@swampdragon.chaosbits.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net> <1299343345-3984-2-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, 5 Mar 2011, Cesar Eduardo Barros wrote:

> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: Jesper Juhl <jj@chaosbits.net>

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
