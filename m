Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 39CD76B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:29:48 -0500 (EST)
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix
 multi-process server scalability issue
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <4B57E442.5060700@redhat.com>
References: <20100117222140.0f5b3939@annuminas.surriel.com>
	 <20100121133448.73BD.A69D9226@jp.fujitsu.com> <4B57E442.5060700@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jan 2010 00:29:35 +0900
Message-ID: <1264087775.1818.26.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Rik. 

Actually, I tested this patch a few days ago.
I met problem like you that hang with udev.

I will debug it when I have a time. :)

On Thu, 2010-01-21 at 00:21 -0500, Rik van Riel wrote:
> Today having 1000 client connections to a forking server is
> considered a lot, but I suspect it could be more common in a
> few years. I would like Linux to be ready for those kinds of
> workloads.
> 

BTW, last year I suggested that removing anon_vma facility itself in 
no swap machine(ie, embedded machine). 

Although your patch add small cost, many of small memory machine don't 
like it if they become to aware this patch.

So I want to make this patch configurable until we prove this patch is
no cost and afterwards we can remove configurable option.

Thanks for new trial to improve VM. :)


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
