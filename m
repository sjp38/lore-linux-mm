Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id AB5C76B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 13:53:26 -0400 (EDT)
Message-ID: <518FD70C.7020608@redhat.com>
Date: Sun, 12 May 2013 13:53:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The pagecache unloved in zone NORMAL?
References: <51671D4D.9080003@bitsync.net> <5186D433.3050301@bitsync.net>
In-Reply-To: <5186D433.3050301@bitsync.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zcalusic@bitsync.net>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On 05/05/2013 05:50 PM, Zlatko Calusic wrote:

> An excellent Konstantin's patch better described here
> http://marc.info/?l=linux-mm&m=136731974301311 is already giving some
> useful additional insight into this problem, just as I expected. Here's
> the data after 31h of server uptime (also see the attached graph):
>
> Node 0, zone    DMA32
>      nr_inactive_file 443705
>    avg_age_inactive_file: 362800
> Node 0, zone   Normal
>      nr_inactive_file 32832
>    avg_age_inactive_file: 38760
>
> I reckon that only aging of the inactive LRU lists is of the interest at
> the moment, because there's currently a streaming I/O of about 8MB/s
> that can be seen on the graphs. Here's how I decipher the numbers:

> The only question I have is, is this a design mistake, or a plain bug?

I believe this is a bug.

> I strongly believe that pages should be reclaimed at speed appropriate
> to the LRU size.

I agree. Aging the pages in one zone 10x as fast as the pages in
another zone could throw off all kinds of things, including detecting
(and preserving) the system working set, page cache readahead thrashing,
etc...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
