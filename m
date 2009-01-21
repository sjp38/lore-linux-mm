Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 06F5B6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:18:01 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so2730192tid.8
        for <linux-mm@kvack.org>; Tue, 20 Jan 2009 23:17:59 -0800 (PST)
Date: Wed, 21 Jan 2009 16:17:18 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: Question: Is  zone->prev_prirotiy  used ?
Message-ID: <20090121071718.GA17969@barrios-desktop>
References: <20090121155219.8b870167.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121155219.8b870167.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 03:52:19PM +0900, KAMEZAWA Hiroyuki wrote:
> Just a question.
> 
> In vmscan.c,  zone->prev_priority doesn't seem to be used.
> 
> Is it for what, now ?

It's the purpose of reclaiming mapped pages before split-lru.
Now, get_scan_ratio can do it. 
I think it is a meaningless variable.
How about Kosaki and Rik ?

> 
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
Kinds Regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
