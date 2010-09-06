Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F50C6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 04:59:42 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o868xeAU014753
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:59:40 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by wpaz24.hot.corp.google.com with ESMTP id o868xcMO031443
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:59:39 -0700
Received: by pwi8 with SMTP id 8so1221267pwi.13
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 01:59:38 -0700 (PDT)
Date: Mon, 6 Sep 2010 01:59:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 14/14] mm: oom_kill: use IS_ERR() instead of strict
 checking
In-Reply-To: <20100906094555.C8BB.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009060155250.10552@chino.kir.corp.google.com>
References: <1283711592-7669-1-git-send-email-segooon@gmail.com> <20100906094555.C8BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kulikov Vasiliy <segooon@gmail.com>, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010, KOSAKI Motohiro wrote:

> > From: Vasiliy Kulikov <segooon@gmail.com>
> > 
> > Use IS_ERR() instead of strict checking.
> 
> Umm...
> 
> I don't like this. IS_ERR() imply an argument is error code. but in
> this case, we don't use error code. -1 mean oom special purpose meaning
> value.
> 

You could make the same argument by saying the current use of PTR_ERR() 
implies an error code.  We've simply hijacked -1UL for simplicity in this 
case and because select_bad_process() can only return one other value 
besides a pointer to a process or NULL.

> So, if we take this direction, It would be better to use EAGAIN or something
> instead -1.
> 

I agree it would probably better to return ERR_PTR(-EAGAIN) instead of 
using -1UL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
