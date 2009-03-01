Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C59B6B00AF
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 15:58:53 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n21Kv3ka016612
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 13:57:03 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n21Kwq6c190608
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 13:58:52 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n21KwqDP001421
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 13:58:52 -0700
Date: Sun, 1 Mar 2009 12:58:49 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-ID: <20090301205849.GA11069@us.ibm.com>
References: <20090119175919.GA7476@us.ibm.com> <20090126223350.610b0283.akpm@linux-foundation.org> <20090127210727.GA9592@us.ibm.com> <25e057c00902270656x1781d04er5703058e47df455f@mail.gmail.com> <20090227213340.GB7174@us.ibm.com> <20090227134616.982fb73a.akpm@linux-foundation.org> <20090228001400.GC7174@us.ibm.com> <20090227162249.bcd0813a.akpm@linux-foundation.org> <20090228030200.GA7342@us.ibm.com> <20090227200805.23d27aa1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090227200805.23d27aa1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, roel.kluin@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 08:08:05PM -0800, Andrew Morton wrote:
> On Fri, 27 Feb 2009 19:02:00 -0800 Gary Hade <garyhade@us.ibm.com> wrote:
> 
> > > > > Should it unlinger?  I have it in the 2.6.30 pile.
> > > > 
> > > > Yes, that would be good. :)
> > > 
> > > What would be good?  Your answer is ambiguous.
> > 
> > Sorry, I was just trying to agree that your plan to wait
> > until 2.6.30 works for me.  Unless someone else objects
> > leave it in your 2.6.30 pile.
> 
> I object ;)
> 
> The change is obviously correct, let's merge it now.

Well, I wouldn't quibble with that. :)  Thanks!

> 
> This could cause presently-working systems to stop working due to
> hitherto-undiscovered bugs.  If so, sue me.

Extremely unlikely IMO.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
