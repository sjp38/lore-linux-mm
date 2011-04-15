Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B965F900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:07:56 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3F55597007566
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:05:05 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3F57nXe101168
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:07:49 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3F57mfT024438
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:07:48 -0600
Subject: Re: [PATCH] make sparse happy with gfp.h
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110415121424.F7A6.A69D9226@jp.fujitsu.com>
References: <20110414234216.9E31DBD9@kernel>
	 <20110415121424.F7A6.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 14 Apr 2011 22:07:46 -0700
Message-ID: <1302844066.16562.1953.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-15 at 12:14 +0900, KOSAKI Motohiro wrote:
> >  #ifdef CONFIG_DEBUG_VM
> > -             BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > +     BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> >  #endif
> > -     }
> >       return z;
> 
> Why don't you use VM_BUG_ON?

I was just trying to make a minimal patch that did a single thing.

Feel free to submit another one that does that.  I'm sure there are a
couple more places that could use similar love.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
