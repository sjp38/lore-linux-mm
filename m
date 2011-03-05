Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F1EEB8D003F
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:22:16 -0500 (EST)
Received: by gxk2 with SMTP id 2so1485186gxk.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:22:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-21-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-21-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:22:15 +0200
Message-ID: <AANLkTi=uVpRUC3BC_AFcR7hLaxz4hqR6dz2YBzjUvCGW@mail.gmail.com>
Subject: Re: [PATCHv2 20/24] sys_swapon: simplify error flow in setup_swap_map_and_extents
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
