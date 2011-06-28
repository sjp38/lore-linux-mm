Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6EB6B0110
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 19:38:12 -0400 (EDT)
Received: by qwa26 with SMTP id 26so516912qwa.14
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 16:38:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308926697-22475-3-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-3-git-send-email-mgorman@suse.de>
Date: Wed, 29 Jun 2011 08:38:10 +0900
Message-ID: <BANLkTi=4K+YaZ9n9K16NNcKz+iMkuZ9K8g@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm: vmscan: Do not apply pressure to slab if we are
 not applying pressure to zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2011 at 11:44 PM, Mel Gorman <mgorman@suse.de> wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
>
> When kswapd applies pressure to zones during node balancing, it checks
> if the zone is above a high+balance_gap threshold. If it is, it does
> not apply pressure but it unconditionally shrinks slab on a global
> basis which is excessive. In the event kswapd is being kept awake due to
> a high small unreclaimable zone, it skips zone shrinking but still
> calls shrink_slab().
>
> Once pressure has been applied, the check for zone being unreclaimable
> is being made before the check is made if all_unreclaimable should be
> set. This miss of unreclaimable can cause has_under_min_watermark_zone
> to be set due to an unreclaimable zone preventing kswapd backing off
> on congestion_wait().
>
> Reported-and-tested-by: P=C3=A1draig Brady <P@draigBrady.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

It does make sense.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
