Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7D22B6B0078
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:31:51 -0500 (EST)
Date: Wed, 21 Nov 2012 11:31:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT PATCH v1 1/5] mm: introduce new field "managed_pages" to
 struct zone
Message-Id: <20121121113149.92e1bcd8.akpm@linux-foundation.org>
In-Reply-To: <50ACE708.5050009@gmail.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
	<1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
	<1353254850-27336-2-git-send-email-jiang.liu@huawei.com>
	<20121119153832.437c7e59.akpm@linux-foundation.org>
	<50AB9A0B.9090105@gmail.com>
	<20121120113119.38d2a635.akpm@linux-foundation.org>
	<50ACE708.5050009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Nov 2012 22:36:56 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> > void mod_zone_managed_pages(struct zone *zone, signed long delta)
> > {
> > 	WARN_ON(system_state != SYSTEM_BOOTING &&
> > 		!is_locked_memory_hotplug());
> > 	zone->managed_pages += delta;
> > }
> This seems a little overhead because __free_pages_bootmem() is on the hot path
> and will be called many times at boot time.

Maybe, maybe not.  These things are measurable so let's not just guess.

But I'm not really recommending that we do this - there are all sorts
of things we *could* check and warn about, but we don't.  Potential
errors in this area don't seem terribly important.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
