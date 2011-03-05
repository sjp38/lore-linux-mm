Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0B9D8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:07:50 -0500 (EST)
Received: by yxt33 with SMTP id 33so1467615yxt.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:07:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-5-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-5-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:07:48 +0200
Message-ID: <AANLkTi=aoWZYvESDf-pOzd8Yj+5vJtdFy62LfRZ87-TL@mail.gmail.com>
Subject: Re: [PATCHv2 04/24] sys_swapon: separate swap_info allocation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Move the swap_info allocation to its own function. Only code movement,
> no functional changes.
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
