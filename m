Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA10440
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 02:43:26 -0500
Subject: Re: [PATCH] MM fix & improvement
References: <87k8yw295p.fsf@atlas.CARNet.hr>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 09 Jan 1999 08:43:09 +0100
In-Reply-To: Zlatko Calusic's message of "09 Jan 1999 08:32:50 +0100"
Message-ID: <87iueg51te.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

> 1) Til' now, writing to swap files & partitions was clustered 
> in 128kb chunks which is too small, especially now when we have swapin 
> readahead (default 64kb). Fragmentation of swap file with such a value 
> is big, so swapin readahead hit rate is probably small. Thus first
> improvement is in increasing on-disk cluster size to much bigger
> value. I chose 512, and it works very well, indeed (see below). All
> this is completely safe.
> 

Oops, in fact 256 is in patch. I used 512 in my preliminary
tests. But, either value will work well.
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
