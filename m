Received: from valerie.inf.elte.hu (valerie.inf.elte.hu [157.181.50.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19764
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 14:58:36 -0400
Date: Sun, 5 Jul 1998 20:57:59 +0200 (MET DST)
From: MOLNAR Ingo <mingo@valerie.inf.elte.hu>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
Message-ID: <Pine.GSO.3.96.980705204753.20176A-100000@valerie.inf.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>


On Sun, 5 Jul 1998, Rik van Riel wrote:

> > I run hdparm -a0 /dev/hda and nothing change. Now the cache take 20Mbyte
> > of memory running cp file /dev/null while memtest 10000000 is running.
> 
> Hdparm only affects _hardware_ readahead and has nothing
> to do with software readahead.

nope, -a0 turns off software readahead. -A controls hardware readahead.

-- mingo

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
