Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D74346B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 02:00:07 -0500 (EST)
Received: by qyk14 with SMTP id 14so9485696qyk.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 23:00:06 -0800 (PST)
Message-ID: <4B4ACC6F.8060801@gmail.com>
Date: Mon, 11 Jan 2010 14:59:59 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>	<1263191277-30373-1-git-send-email-shijie8@gmail.com> <20100111153802.f3150117.minchan.kim@barrios-desktop>
In-Reply-To: <20100111153802.f3150117.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


> Frankly speaking, I am not sure this ir right way.
> This patch is adding to fine-grained locking overhead
>
> As you know, this functions are one of hot pathes.
>    
Yes. But the PCP suffers  most of the  pressure  ,I think.
free_one_page() handles (order != 0) most of the time which is 
relatively rarely
executed.

> In addition, we didn't see the any problem, until now.
> It means out of synchronization in ZONE_ALL_UNRECLAIMABLE
> and pages_scanned are all right?
>
>    
Maybe it has already caused  a problem,  while the problem is hard to 
find out. :)
> If it is, we can move them out of zone->lock, too.
> If it isn't, we need one more lock, then.
>
> Let's listen other mm guys's opinion.
>
>    
Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
