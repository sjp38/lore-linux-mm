Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PICIjq008188
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:12:18 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PICItH136636
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:12:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PICHlH005459
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:12:18 -0400
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071025180514.GB20345@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
	 <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
	 <1193332528.4039.156.camel@localhost>
	 <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
	 <20071025180514.GB20345@skynet.ie>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 11:12:15 -0700
Message-Id: <1193335935.24087.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 19:05 +0100, Mel Gorman wrote:
> I think Dave has a point so I would be happy with a boolean. We don't really
> care what the type is, we care about if it can be removed or not.
> 
> It also occurs to me from the "can we remove it perspective" that you may
> also want to check if the pageblock is entirely free or not. You can encounter
> a pageblock that is "Unmovable" but entirely free so it could be removed. 

The other option is to make it somewhat of a "removability score".  If
it has non-relocatable pages, then it gets a crappy score.  If it is
relocatable, give it more points.  If it has more free pages, give it
even more.  If the pages contain images of puppies, take points away.

That way, if something in userspace says, "we need to give memory back",
it can go find the _best_ section from which to give it.

But, maybe I'm just over-enginnering now. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
