Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 993346B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 04:45:09 -0500 (EST)
Received: by iacb35 with SMTP id b35so21958347iac.14
        for <linux-mm@kvack.org>; Mon, 26 Dec 2011 01:45:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111223141619.GA19720@x61.redhat.com>
References: <20111223141619.GA19720@x61.redhat.com>
Date: Mon, 26 Dec 2011 18:45:08 +0900
Message-ID: <CAEwNFnBYVvqQO6Q2wUoUcpy0FdtVrD1A6R=hVK0=VpNKDzubzQ@mail.gmail.com>
Subject: Re: [PATCH] tracing: adjust shrink_slab beginning trace event name
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, Dec 23, 2011 at 11:16 PM, Rafael Aquini <aquini@redhat.com> wrote:
> While reviewing vmscan tracing events, I realized all functions which est=
ablish paired tracepoints (one at the beginning and another at the end of t=
he function block) were following this naming pattern:
> =C2=A0<tracepoint-name>_begin
> =C2=A0<tarcepoint-name>_end
>
> However, the 'beginning' tracing event for shrink_slab() did not follow t=
he aforementioned naming pattern. This patch renames that trace event to ad=
just this naming inconsistency.
>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
