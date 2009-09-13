Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4856A6B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 19:24:38 -0400 (EDT)
Received: by pxi1 with SMTP id 1so2097029pxi.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 16:24:45 -0700 (PDT)
Date: Mon, 14 Sep 2009 08:24:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Isolated(anon) and Isolated(file)
Message-Id: <20090914082430.13e06e4e.minchan.kim@barrios-desktop>
In-Reply-To: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
References: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Sep 2009 20:42:38 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> Hi KOSAKI-san,
> 
> May I question the addition of Isolated(anon) and Isolated(file)
> lines to /proc/meminfo?  I get irritated by all such "0 kB" lines!
> 
> I see their appropriateness and usefulness in the Alt-Sysrq-M-style
> info which accompanies an OOM; and I see that those statistics help
> you to identify and fix bugs of having too many pages isolated.

Right. 
 
> But IMHO they're too transient to be appropriate in /proc/meminfo:
> by the time the "cat /proc/meminfo" is done, the situation is very
> different (or should be once the bugs are fixed).

I agree. 
 
> Almost all its numbers are transient, of course, but these seem
> so much so that I think /proc/meminfo is better off without them
> (compressing more info into fewer lines).
> 
> Perhaps I'm in the minority: if others care, what do they think?

At that time, we need isolated page count per zone. 
So we added it in zone_stat_item. 

As you know, most of zone_stat_item are fields of meminfo. 
So, I supported it as part of meminfo without serious thinking.
 
Now I agree with your opinion. 

It's very transient so it is valuable when OOM or Sysrq happens. 
If you get irritated by it, we can remove things related to meminfo 
but keep isolated count, then when we meets OOM, we can show it. 

Let's listen to others.

> Hugh


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
