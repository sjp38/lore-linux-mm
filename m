Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LLQnev008056
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 17:26:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LLQnR6433074
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 17:26:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LLQmsc012069
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 17:26:48 -0400
Subject: Re: [RFC][PATCH 1/9] /proc/pid/pagemap update
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070821212357.GG30556@waste.org>
References: <20070821204248.0F506A29@kernel>
	 <20070821212357.GG30556@waste.org>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 14:26:43 -0700
Message-Id: <1187731603.16177.82.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 16:23 -0500, Matt Mackall wrote:
> 
> > Matt, if you're OK with these, do you mind if I send
> > the update into -mm, or would you like to do it?
> 
> Hmmm, is the below working for you? I was having trouble with it. 

I think that was just a patch you sent as your work-in-progress a couple
of weeks ago.  Either I messed it up when merging, or it never compiled.
The subsequent patches make it work again.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
