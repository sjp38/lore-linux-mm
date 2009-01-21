Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0888B6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 18:54:16 -0500 (EST)
Date: Thu, 22 Jan 2009 08:54:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Question: Is  zone->prev_prirotiy  used ?
In-Reply-To: <20090121071718.GA17969@barrios-desktop>
References: <20090121155219.8b870167.kamezawa.hiroyu@jp.fujitsu.com> <20090121071718.GA17969@barrios-desktop>
Message-Id: <20090123084500.421C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> On Wed, Jan 21, 2009 at 03:52:19PM +0900, KAMEZAWA Hiroyuki wrote:
> > Just a question.
> > 
> > In vmscan.c,  zone->prev_priority doesn't seem to be used.
> > 
> > Is it for what, now ?
> 
> It's the purpose of reclaiming mapped pages before split-lru.
> Now, get_scan_ratio can do it. 
> I think it is a meaningless variable.
> How about Kosaki and Rik ?

Right.
I thought this variable can use for future enhancement. 
then I didn't removed.

Kamezawa-san, does its variable prevent your development?
if so, I don't oppose removing.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
