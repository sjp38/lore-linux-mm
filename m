Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 60A388D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:08:21 -0500 (EST)
Received: by gyb13 with SMTP id 13so1516792gyb.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:08:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-6-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-6-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:08:19 +0200
Message-ID: <AANLkTik29hmXwgnJjhehESNWiNwnTpQFOiJo-NJEoEL1@mail.gmail.com>
Subject: Re: [PATCHv2 05/24] sys_swapon: simplify error return from swap_info allocation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> At this point in sys_swapon, there is nothing to free. Return directly
> instead of jumping to the cleanup block at the end of the function.
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
