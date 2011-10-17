Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D49FC6B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 23:09:33 -0400 (EDT)
Received: by wwf5 with SMTP id 5so846859wwf.26
        for <linux-mm@kvack.org>; Sun, 16 Oct 2011 20:09:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANsGZ6Zs0sPMqcToGpw8H1vLcAewyj4aii+iy0V9oyhk7RqzjA@mail.gmail.com>
References: <201110122012.33767.pluto@agmk.net> <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <CA+55aFyTif3k0-wb+1zS8b+hKT13pL0T_qtVzAz2HW5U9=yoMg@mail.gmail.com> <CANsGZ6Zs0sPMqcToGpw8H1vLcAewyj4aii+iy0V9oyhk7RqzjA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 16 Oct 2011 20:09:12 -0700
Message-ID: <CA+55aFwfkiH7NN18ve2y0PUK8UobagHfpTJ4QoZSL1KLLUMFTw@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Sun, Oct 16, 2011 at 8:02 PM, Hugh Dickins <hughd@google.com> wrote:
> I've not read through and digested Andrea's reply yet, but I'd say
> this is not something we need to rush into 3.1 at the last moment,
> before it's been fully considered: the bug here is hard to hit,
> ancient, made more likely in 2.6.35 by compaction and in 2.6.38 by
> THP's reliance on compaction, but not a regression in 3.1 at all - let
> it wait until stable.

Ok, thanks. Just wanted to check.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
