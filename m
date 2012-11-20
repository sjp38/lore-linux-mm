Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2B4486B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 01:27:13 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4334859pbc.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 22:27:12 -0800 (PST)
Date: Mon, 19 Nov 2012 22:24:00 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC 3/3] man-pages: Add man page for vmpressure_fd(2)
Message-ID: <20121120062400.GA9468@lizard>
References: <20121107105348.GA25549@lizard>
 <20121107110152.GC30462@lizard>
 <20121119215211.6370ac3b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121119215211.6370ac3b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Mon, Nov 19, 2012 at 09:52:11PM -0800, Andrew Morton wrote:
> On Wed, 7 Nov 2012 03:01:52 -0800 Anton Vorontsov <anton.vorontsov@linaro.org> wrote:
> >        Upon  these  notifications,  userland programs can cooperate with
> >        the kernel, achieving better system's memory management.
> 
> Well I read through the whole thread and afaict the above is the only
> attempt to describe why this patchset exists!

Thanks for taking a look. :)

> How about we step away from implementation details for a while and
> discuss observed problems, use-cases, requirements and such?  What are
> we actually trying to achieve here?

We try to make userland freeing resources when the system becomes low on
memory. Once we're short on memory, sometimes it's better to discard
(free) data, rather than let the kernel to drain file caches or even start
swapping.

In Android case, the data includes all idling applications' state, some of
which might be saved on the disk anyway -- so we don't need to swap apps,
we just kill them. Another Android use-case is to kill low-priority tasks
(e.g. currently unimportant services -- background/sync daemons, etc.).

There are other use cases: VPS/containers balancing, freeing browser's old
pages renders on desktops, etc. But I'll let folks speak for their use
cases, as I truly know about Android/embedded only.

But in general, it's the same stuff as the in-kernel shrinker, except that
we try to make it available for the userland: the userland knows better
about its memory, so we want to let it help with the memory management.

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
