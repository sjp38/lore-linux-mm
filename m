Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5AE406B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:32:28 -0500 (EST)
Received: by ywh5 with SMTP id 5so47139126ywh.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 18:32:26 -0800 (PST)
Message-ID: <4B4BDF35.1060102@gmail.com>
Date: Tue, 12 Jan 2010 10:32:21 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>	<1263191277-30373-1-git-send-email-shijie8@gmail.com>	<20100111153802.f3150117.minchan.kim@barrios-desktop>	<20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>	<4B4BD849.7050007@gmail.com> <20100112110740.54813cf6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112110740.54813cf6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


>> How about the `pages_scanned' ?
>> It's protected by the zone->lru_lock in shrink_{in}active_list().
>>
>>      
> Zero-clear by page-scanned is done by a write (atomic). Then, possible race
> will be this update,
>
> 	zone->pages_scanend += scanned;
>
> And failing to reset the number. But, IMHO, failure to reset this counter
> is not a big problem. We'll finally reset this when we free the next
>    
This is a good reason to me.  Thanks a lot.
> page. So, I have no concerns about resetting this counter.
>
> My only concern is race with other flags.
>
> Thanks,
> -Kame
>
>
>
>
>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
