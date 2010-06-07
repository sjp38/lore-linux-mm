Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBFF6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:49:12 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o57Jn9PG030056
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 12:49:09 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz24.hot.corp.google.com with ESMTP id o57Jn7Lj008764
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 12:49:08 -0700
Received: by pwi7 with SMTP id 7so546296pwi.7
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 12:49:07 -0700 (PDT)
Date: Mon, 7 Jun 2010 12:49:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
In-Reply-To: <AANLkTilNvqKqjiKUdKRjILBiTxy5L7-IpS4dTSzjzPDJ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006071248250.30389@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com> <20100607125828.GW4603@balbir.in.ibm.com> <AANLkTilNvqKqjiKUdKRjILBiTxy5L7-IpS4dTSzjzPDJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2010, Minchan Kim wrote:

> Yes.  Although main thread detach mm, sub-thread still may have the mm.
> As you have confused, I think this function name isn't good.
> So I suggested following as.
> 

I think the function name is fine, it describes exactly what it does: it 
finds the relevant mm for the task and returns it with task_lock() held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
