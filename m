Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D40E88D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 13:51:05 -0500 (EST)
Received: by gxk2 with SMTP id 2so1509337gxk.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 10:51:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
References: <1299350956-5614-1-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 20:51:04 +0200
Message-ID: <AANLkTin=gQCAf9PNjsxwJg=jF2mB-0dyuzfmYN42UQ9S@mail.gmail.com>
Subject: Re: [PATCH] mm: remove inline from scan_swap_map
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org

On Sat, Mar 5, 2011 at 8:49 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
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

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
