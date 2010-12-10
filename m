Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DABBB6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 22:53:40 -0500 (EST)
Received: by iwn1 with SMTP id 1so4853966iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 19:53:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101209141317.60d14fb5.akpm@linux-foundation.org>
References: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com>
	<20101209141317.60d14fb5.akpm@linux-foundation.org>
Date: Fri, 10 Dec 2010 12:53:39 +0900
Message-ID: <AANLkTikxRpiRdXpxgAJWaOhhA32Fup97DLYA9gNUS5TP@mail.gmail.com>
Subject: Re: [PATCH] vmscan: make kswapd use a correct order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 7:13 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, =A03 Dec 2010 01:00:49 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> +static bool kswapd_try_to_sleep(pg_data_t *pgdat, int order)
>
> OT: kswapd_try_to_sleep() does a
> trace_mm_vmscan_kswapd_sleep(pgdat->node_id) if it sleeps for a long
> time, but doesn't trace anything at all if it does a short sleep.
> Where's the sense in that?
>

AFAIU, short sleep is _sleep_ but that trace's goal is to count only long s=
leep.
In addition, short sleep is a just ready to go or not long sleep so I
think we don't need short sleep trace.
And for knowing short sleep count, we can use
KSWAPD_{LOW|HIGH}_WMARK_HIT_QUICKLY.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
