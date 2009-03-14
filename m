Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2DA446B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 20:27:45 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so643244wfa.11
        for <linux-mm@kvack.org>; Fri, 13 Mar 2009 17:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
	 <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
Date: Sat, 14 Mar 2009 09:27:43 +0900
Message-ID: <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com>
Subject: Re: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com, lee.schermerhorn@hp.com, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi, David.

It seems your patch is better than mine.  Thanks. :)
But my concern is that as Peter pointed out, unevictable lru's
solution is not fundamental one.

He want to remove ramfs page from lru list to begin with.
I guess Andrew also thought same thing with Peter.

I think it's a fundamental solution. but it may be long term solution.
This patch can solve NOMMU problem in current status.

Andrew, What do you think about it ?

On Sat, Mar 14, 2009 at 2:33 AM, David Howells <dhowells@redhat.com> wrote:
>
> The first patch causes the mlock() bits added by CONFIG_UNEVICTABLE_LRU to be
> unavailable in NOMMU mode.
>
> The second patch makes CONFIG_UNEVICTABLE_LRU available in NOMMU mode.
>
> David
>



-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
