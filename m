Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C37786B004D
	for <linux-mm@kvack.org>; Sat, 24 Dec 2011 00:13:08 -0500 (EST)
Received: by yenq10 with SMTP id q10so7383297yen.14
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 21:13:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111223141619.GA19720@x61.redhat.com>
References: <20111223141619.GA19720@x61.redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 24 Dec 2011 00:12:45 -0500
Message-ID: <CAHGf_=quc6C8XGBys45_9szr2ssn5sBN_tEpJ_1tSYdg+tzD1Q@mail.gmail.com>
Subject: Re: [PATCH] tracing: adjust shrink_slab beginning trace event name
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

2011/12/23 Rafael Aquini <aquini@redhat.com>:
> While reviewing vmscan tracing events, I realized all functions which est=
ablish paired tracepoints (one at the beginning and another at the end of t=
he function block) were following this naming pattern:
> =A0<tracepoint-name>_begin
> =A0<tarcepoint-name>_end
>
> However, the 'beginning' tracing event for shrink_slab() did not follow t=
he aforementioned naming pattern. This patch renames that trace event to ad=
just this naming inconsistency.
>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

I don't think it's big issue. but seems no harm change.
 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> ---
> =A0include/trace/events/vmscan.h | =A0 =A02 +-
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A02 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.=
h
> index edc4b3d..615bd6d 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -179,7 +179,7 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, m=
m_vmscan_memcg_softlimit_re
> =A0 =A0 =A0 =A0TP_ARGS(nr_reclaimed)
> =A0);
>
> -TRACE_EVENT(mm_shrink_slab_start,
> +TRACE_EVENT(mm_shrink_slab_begin,
> =A0 =A0 =A0 =A0TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0long nr_objects_to_shrink, unsigned long p=
gs_scanned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long lru_pgs, unsigned long cache=
_items,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f54a05b..b24a593 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -301,7 +301,7 @@ unsigned long shrink_slab(struct shrink_control *shri=
nk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (total_scan > max_pass * 2)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scan =3D max_pass * =
2;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_shrink_slab_start(shrinker, shrink=
, nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_shrink_slab_begin(shrinker, shrink=
, nr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0nr_pages_scanned, lru_pages,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0max_pass, delta, total_scan);
>
> --
> 1.7.7.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
