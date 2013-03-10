Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A00826B0044
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 03:28:56 -0400 (EDT)
Date: Sun, 10 Mar 2013 08:28:54 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2, part1 22/29] mm/SPARC: use common help functions to
	free reserved pages
Message-ID: <20130310072854.GA16475@merkur.ravnborg.org>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com> <1362896833-21104-23-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362896833-21104-23-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 10, 2013 at 02:27:05PM +0800, Jiang Liu wrote:
> Use common help functions to free reserved pages.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Cc: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Sam Ravnborg <sam@ravnborg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
