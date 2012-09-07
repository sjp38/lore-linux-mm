Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 033236B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 05:17:06 -0400 (EDT)
Date: Fri, 7 Sep 2012 10:17:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 0/4] memory-hotplug: handle page race between
 allocation and isolation
Message-ID: <20120907091701.GW11266@suse.de>
References: <1346978372-17903-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1346978372-17903-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

On Fri, Sep 07, 2012 at 09:39:28AM +0900, Minchan Kim wrote:
> Memory hotplug has a subtle race problem so this patchset fixes the problem
> (Look at [3/3] for detail and please confirm the problem before review
> other patches in this series.)
> 
>  [1/4] is just clean up and help for [2/4].
>  [2/4] keeps the migratetype information to freed page's index field
>        and [3/4] uses the information.
>  [3/4] fixes the race problem with [2/4]'s information.
>  [4/4] enhance memory-hotremove operation success ratio
> 
> After applying [2/4], migratetype argument in __free_one_page
> and free_one_page is redundant so we can remove it but I decide
> to not touch them because it increases code size about 50 byte.
> 
> This patchset is based on mmotm-2012-09-06-16-46
> 

Nothing jumped out and poked me in the eye so for the series;

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
