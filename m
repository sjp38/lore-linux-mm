Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E0206B00B2
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 23:57:39 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KG000GSLOG1IE91@VL-MH-MR002.ip.videotron.ca> for
 linux-mm@kvack.org; Wed, 04 Mar 2009 23:57:38 -0500 (EST)
Date: Wed, 04 Mar 2009 23:57:37 -0500 (EST)
From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC] atomic highmem kmap page pinning
In-reply-to: <20090305132054.888396da.minchan.kim@barrios-desktop>
Message-id: <alpine.LFD.2.00.0903042350210.5511@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
 <20090304171429.c013013c.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
 <20090305132054.888396da.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 2009, Minchan Kim wrote:

> On Wed, 04 Mar 2009 21:37:43 -0500 (EST)
> Nicolas Pitre <nico@cam.org> wrote:
> 
> > My assertion is that the cost is negligible.  This is why I'm asking you 
> > why you think this is a big cost.
> 
> Of course, I am not sure whether it's big cost or not. 
> But I thought it already is used in many fs, driver.
> so, whether it's big cost depends on workload type .
> 
> However, This patch is needed for VIVT and no coherent cache.
> Is right ?
> 
> If it is right, it will add unnessary overhead in other architecture 
> which don't have this problem.
> 
> I think it's not desirable although it is small cost.
> If we have a other method which avoids unnessary overhead, It would be better.
> Unfortunately, I don't have any way to solve this, now. 

OK.  What about this patch then:
