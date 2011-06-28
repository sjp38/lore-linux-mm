Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 564CE6B0101
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 19:23:22 -0400 (EDT)
Received: by mail-qw0-f41.google.com with SMTP id 26so511738qwa.14
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 16:23:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308926697-22475-4-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-4-git-send-email-mgorman@suse.de>
Date: Wed, 29 Jun 2011 08:23:20 +0900
Message-ID: <BANLkTini5rmyX_7wnAx8SA4Zw-wn21K9GQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: vmscan: Evaluate the watermarks against the
 correct classzone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2011 at 11:44 PM, Mel Gorman <mgorman@suse.de> wrote:
> When deciding if kswapd is sleeping prematurely, the classzone is
> taken into account but this is different to what balance_pgdat() and
> the allocator are doing. Specifically, the DMA zone will be checked
> based on the classzone used when waking kswapd which could be for a
> GFP_KERNEL or GFP_HIGHMEM request. The lowmem reserve limit kicks in,
> the watermark is not met and kswapd thinks its sleeping prematurely
> keeping kswapd awake in error.
>
> Reported-and-tested-by: P=C3=A1draig Brady <P@draigBrady.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
