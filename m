Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C171F8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:39:35 -0500 (EST)
Received: by iyf13 with SMTP id 13so5379322iyf.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 07:39:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
References: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
Date: Tue, 8 Mar 2011 00:39:34 +0900
Message-ID: <AANLkTimsm7KmgdfUozrJ8=SFfBtikZJuCdiyrNtgVphk@mail.gmail.com>
Subject: Re: [PATCH] mm: remove inline from scan_swap_map
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org

On Sun, Mar 6, 2011 at 3:49 AM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> scan_swap_map is a large function (224 lines), with several loops and a
> complex control flow involving several gotos.
>
> Given all that, it is a bit silly that is is marked as inline. The
> compiler agrees with me: on a x86-64 compile, it did not inline the
> function.
>
> Remove the "inline" and let the compiler decide instead.
>
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
