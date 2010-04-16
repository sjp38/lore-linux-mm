Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 994BA6B01E3
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 05:46:30 -0400 (EDT)
Date: Fri, 16 Apr 2010 10:50:02 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if
 current is kswapd
Message-ID: <20100416105002.191adeb1@lxorguk.ukuu.org.uk>
In-Reply-To: <20100415233339.GW2493@dastard>
References: <20100415013436.GO2493@dastard>
	<20100415130212.D16E.A69D9226@jp.fujitsu.com>
	<20100415131106.D174.A69D9226@jp.fujitsu.com>
	<64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
	<20100415093214.GV2493@dastard>
	<85DB7083-8E78-4884-9E76-5BD803C530EF@freebsd.org>
	<20100415233339.GW2493@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

> No. If you are doing full disk seeks between random chunks, then you
> still lose a large amount of throughput. e.g. if the seek time is
> 10ms and your IO time is 10ms for each 4k page, then increasing the
> size ito 64k makes it 10ms seek and 12ms for the IO. We might increase
> throughput but we are still limited to 100 IOs per second. We've
> gone from 400kB/s to 6MB/s, but that's still an order of magnitude
> short of the 100MB/s full size IOs with little in way of seeks
> between them will acheive on the same spindle...

The usual armwaving numbers for ops/sec for an ATA disk are in the 200
ops/sec range so that seems horribly credible.

But then I've never quite understood why our anonymous paging isn't
sorting stuff as best it can and then using the drive as a log structure
with in memory metadata so it can stream the pages onto disk. Read
performance is goig to be similar (maybe better if you have a log tidy
when idle), write ought to be far better.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
