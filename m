Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 60F518D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 14:15:54 -0500 (EST)
Date: Sat, 5 Mar 2011 20:15:18 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCHv2 08/24] sys_swapon: move setting of error nearer use
In-Reply-To: <1299343345-3984-9-git-send-email-cesarb@cesarb.net>
Message-ID: <alpine.LNX.2.00.1103052014490.32044@swampdragon.chaosbits.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net> <1299343345-3984-9-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, 5 Mar 2011, Cesar Eduardo Barros wrote:

> Move the setting of the error variable nearer the goto in a few places.
> 
> Avoids calling PTR_ERR() if not IS_ERR() in two places, and makes the
> error condition more explicit in two other places.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Looks good to me.

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
