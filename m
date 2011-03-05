Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E0F198D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:10:51 -0500 (EST)
Received: by yxt33 with SMTP id 33so1468481yxt.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:10:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-7-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-7-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:10:49 +0200
Message-ID: <AANLkTikdXLUaE2dJgEzBFpc_e6Pgu6rwML+dowdJ22w3@mail.gmail.com>
Subject: Re: [PATCHv2 06/24] sys_swapon: simplify error flow in alloc_swap_info
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Since there is no cleanup to do, there is no reason to jump to a label.
> Return directly instead.
>
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
