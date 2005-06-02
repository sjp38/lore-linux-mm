Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j52KAumD592758
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 16:10:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j52KAuuC242688
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 14:10:56 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j52KAttL004615
	for <linux-mm@kvack.org>; Thu, 2 Jun 2005 14:10:55 -0600
Message-ID: <429F67C4.9060506@austin.ibm.com>
Date: Thu, 02 Jun 2005 15:10:44 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <423970000.1117668514@flay> <429E483D.8010106@yahoo.com.au> <434510000.1117670555@flay> <429E50B8.1060405@yahoo.com.au> <429F2B26.9070509@austin.ibm.com> <429F631E.6020401@engr.sgi.com>
In-Reply-To: <429F631E.6020401@engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> Could someone point me at the "Page migration defrag" patch, or
> describe what this is.  Does this depend on the page migration
> patches from memory hotplug to move pages or is it something
> different?

I don't think anybody has actually written such a patch yet (correct me 
if I'm wrong).  When somebody does it will certainly depend on the page 
migration patches.  As far as describing what it is, the concept is 
pretty simple.  Migrate in use pieces of memory around to make lots of 
smaller unallocated memory into fewer larger unallocated memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
