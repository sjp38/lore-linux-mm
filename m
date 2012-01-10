Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9A8666B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 17:33:32 -0500 (EST)
Date: Tue, 10 Jan 2012 14:33:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-Id: <20120110143330.44cf1ccf.akpm@linux-foundation.org>
In-Reply-To: <20111227135658.08c8016a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	<20111221095249.GA28474@tiehlicka.suse.cz>
	<20111221225512.GG23662@dastard>
	<1324630880.562.6.camel@rybalov.eng.ttk.net>
	<20111223102027.GB12731@dastard>
	<1324638242.562.15.camel@rybalov.eng.ttk.net>
	<20111223204503.GC12731@dastard>
	<20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20111227035730.GA22840@barrios-laptop.redhat.com>
	<20111227135658.08c8016a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Dave Chinner <david@fromorbit.com>, nowhere <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Dec 2011 13:56:58 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Hmm, if I understand correctly,
> 
>  - dd's speed down is caused by kswapd's cpu consumption.
>  - kswapd's cpu consumption is enlarged by shrink_slab() (by perf)
>  - kswapd can't stop because NORMAL zone is small.
>  - memory reclaim speed is enough because dd can't get enough cpu.
> 
> I wonder reducing to call shrink_slab() may be a help but I'm not sure
> where lock conention comes from...

Nikolay, it sounds as if this problem has only recently started
happening?  Was 3.1 OK?

If so, we should work out what we did post-3.1 to cause this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
