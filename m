Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA02009
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 08:43:58 -0500
Date: Thu, 26 Mar 1998 14:09:47 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: shrink_mmap ()?
In-Reply-To: <Pine.SUN.3.95.980326175034.17975N-100000@Kabini>
Message-ID: <Pine.LNX.3.91.980326140853.1002A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chirayu Patel <chirayu@wipro.tcpn.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 1998, Chirayu Patel wrote:

> I was going through the source for shrink_mmap.......
> 
> We are freeing a page with count = 1 (referenced by one process only) but
> we are not manipulating any page table entries. Why? Shouldnt we be
> manipulating the page table entries or where are the page table entries
> getting manipulated?
> 
> I know I have missed something terribly obvious over here. Can someone
> please help me out. 

When the count is 1, the page cache _is_ the only reference to
the page.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
