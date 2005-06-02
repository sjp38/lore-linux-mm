Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j52FqHmD419790
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 11:52:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j52FqHJj154948
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 09:52:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j52FqG7n001105
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 09:52:16 -0600
Message-ID: <429F2B26.9070509@austin.ibm.com>
Date: Thu, 02 Jun 2005 10:52:06 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au> <434510000.1117670555@flay> <429E50B8.1060405@yahoo.com.au>
In-Reply-To: <429E50B8.1060405@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> I see your point... Mel's patch has failure cases though.
> For example, someone turns swap off, or mlocks some memory
> (I guess we then add the page migration defrag patch and
> problem is solved?).

This reminds me that page migration defrag will be pretty useless 
without something like this done first.  There will be stuff that can't 
be migrated and it needs to be grouped together somehow.

In summary here are the reasons I see to run with Mel's patch:

1. It really helps with medium-large allocations under memory pressure.
2. Page migration defrag will need it.
3. Memory hotplug remove will need it.

On the downside we have:

1. Slightly more complexity in the allocator.

I'd personally trade a little extra complexity for any of the 3 upsides.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
