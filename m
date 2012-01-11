Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id AF6956B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 18:17:51 -0500 (EST)
Received: by iafj26 with SMTP id j26so2355177iaf.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 15:17:50 -0800 (PST)
Date: Wed, 11 Jan 2012 15:17:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: memcg: add mlock statistic in memory.stat
In-Reply-To: <1326321668-5422-1-git-send-email-yinghan@google.com>
Message-ID: <alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Wed, 11 Jan 2012, Ying Han wrote:

> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> the metrics exported by memcg, especially is used together with "uneivctable"
> lru stat.
> 
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -10,6 +10,7 @@ enum {
>  	/* flags for mem_cgroup and file and I/O status */
>  	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
>  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> +	PCG_MLOCK, /* page is accounted as "mlock" */
>  	/* No lock in page_cgroup */
>  	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
>  	__NR_PCG_FLAGS,

Is this really necessary?  KAMEZAWA-san is engaged in trying to reduce
the number of PageCgroup flags, and I expect that in due course we shall
want to merge them in with Page flags, so adding more is unwelcome.
I'd  have thought that with memcg_ hooks in the right places,
a separate flag would not be necessary?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
