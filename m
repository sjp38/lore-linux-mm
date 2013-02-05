Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 12:01:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130205120137.GG21389@suse.de>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
 <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 05, 2013 at 05:21:52PM +0800, Lin Feng wrote:
> get_user_pages() always tries to allocate pages from movable zone, which is not
>  reliable to memory hotremove framework in some case.
> 
> This patch introduces a new library function called get_user_pages_non_movable()
>  to pin pages only from zone non-movable in memory.
> It's a wrapper of get_user_pages() but it makes sure that all pages come from
> non-movable zone via additional page migration.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Zach Brown <zab@redhat.com>
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>

I already had started the review of V1 before this was sent
unfortunately. However, I think the feedback I gave for V1 is still
valid so I'll wait for comments on that review before digging further.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
