Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2CE90023D
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 10:24:06 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2924077pwi.14
        for <linux-mm@kvack.org>; Sat, 25 Jun 2011 07:23:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308926697-22475-1-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
From: Andrew Lutomirski <luto@mit.edu>
Date: Sat, 25 Jun 2011 08:23:37 -0600
Message-ID: <BANLkTintLEcJvNzzspYRUV8fCx9=9dGDnA@mail.gmail.com>
Subject: Re: [PATCH 0/4] Stop kswapd consuming 100% CPU when highest zone is small
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2011 at 8:44 AM, Mel Gorman <mgorman@suse.de> wrote:
> (Built this time and passed a basic sniff-test.)
>
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour. =A0Unfortunately, if the highest zone is
> small, a problem occurs.
>

[...]

I've been running these for a couple days with no problems, although I
haven't been trying to reproduce the problem.  (Well, no problems
related to memory management.)

I suspect that my pet unnecessary-OOM-kill bug is still around, but
that's probably not related, especially since I can trigger it if I
stick 8 GB of RAM in this laptop.

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
