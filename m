Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id EEBA06B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 07:49:42 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so701419obc.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 04:49:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904554270@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
	<e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
	<20120105155950.9e49651b.kamezawa.hiroyu@jp.fujitsu.com>
	<84FF21A720B0874AA94B46D76DB9826904554270@008-AM1MPN1-003.mgdnok.nokia.com>
Date: Thu, 5 Jan 2012 14:49:42 +0200
Message-ID: <CAOJsxLF706VeThxqWostJr84N_8q8UXoQzxGmMXj8mpgTLCagg@mail.gmail.com>
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Thu, Jan 5, 2012 at 1:26 PM,  <leonid.moiseichuk@nokia.com> wrote:
> I agree that hooking alloc_pages is ugly way. So alternatives I see:
>
> - shrinkers (as e.g. Android OOM used) but shrink_slab called only from
> try_to_free_pages only if we are on slow reclaim path on memory allocation,
> so it cannot be used for e.g. 75% memory tracking or when pages released to
> notify user space that we are OK. But according to easy to use it will be the
> best approach.
>
> - memcg-kind of changes like mem_cgroup_newpage_charge/uncharge_page but
> without blocking decision making logic. Seems to me more changes. Threshold
> currently in memcg set 128 pages per CPU, that is quite often for level
> tracking needs.
>
> - tracking situation using timer? Maybe not due to will impact battery.

Can we hook into mm/vmscan.c and mm/page-writeback.c for this?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
