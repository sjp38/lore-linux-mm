Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E78886B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 17:57:13 -0500 (EST)
Date: Tue, 5 Mar 2013 23:57:11 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH v1 22/33] mm/SPARC: use common help functions to
	free reserved pages
Message-ID: <20130305225711.GA12811@merkur.ravnborg.org>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com> <1362495317-32682-23-git-send-email-jiang.liu@huawei.com> <20130305195845.GB12225@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130305195845.GB12225@merkur.ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

On Tue, Mar 05, 2013 at 08:58:46PM +0100, Sam Ravnborg wrote:
> On Tue, Mar 05, 2013 at 10:55:05PM +0800, Jiang Liu wrote:
> > Use common help functions to free reserved pages.
> 
> I like how this simplify things!
> 
> Please consider how you can also cover the HIGHMEM case,
> so map_high_region(...) is simplified too (in init_32.c).

I now see this is done in a later patch - good!

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
