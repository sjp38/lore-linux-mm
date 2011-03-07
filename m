Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 570AD8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:22:25 -0500 (EST)
Received: by yxt33 with SMTP id 33so2019218yxt.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 01:22:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-9-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-9-git-send-email-cesarb@cesarb.net>
Date: Mon, 7 Mar 2011 11:22:23 +0200
Message-ID: <AANLkTi=XHOg_oqCoMPw=m9SkJucQAfJ0bB+kQ14Rs_QF@mail.gmail.com>
Subject: Re: [PATCHv2 08/24] sys_swapon: move setting of error nearer use
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Move the setting of the error variable nearer the goto in a few places.
>
> Avoids calling PTR_ERR() if not IS_ERR() in two places, and makes the
> error condition more explicit in two other places.
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
