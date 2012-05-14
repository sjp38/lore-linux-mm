Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 4E20A6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 01:56:41 -0400 (EDT)
Received: by ggm4 with SMTP id 4so2402788ggm.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 22:56:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1205132200150.6148@eggly.anvils>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132200150.6148@eggly.anvils>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 14 May 2012 01:56:20 -0400
Message-ID: <CAHGf_=rr9ATkYBnwas7BSfPpD=cCf1jotguOdR1ysBnWznJ-GA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: trivial cleanups in vmscan.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 14, 2012 at 1:01 AM, Hugh Dickins <hughd@google.com> wrote:
> Utter trivia in mm/vmscan.c, mostly just reducing the linecount slightly;
> most exciting change being get_scan_count() calling vmscan_swappiness()
> once instead of twice.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
