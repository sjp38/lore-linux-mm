Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k130ZscK017339
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 19:35:54 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k130XuXd266672
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 17:33:57 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k130ZrWJ024063
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 17:35:54 -0700
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
	controller
From: chandra seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <20060202035402.A29667403A@sv1.valinux.co.jp>
References: <20060119080408.24736.13148.sendpatchset@debian>
	 <20060131023000.7915.71955.sendpatchset@debian>
	 <1138762698.3938.16.camel@localhost.localdomain>
	 <20060201053958.CE35B74035@sv1.valinux.co.jp>
	 <1138843560.3939.26.camel@localhost.localdomain>
	 <20060202035402.A29667403A@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Thu, 02 Feb 2006 16:37:37 -0800
Message-Id: <1138927057.3914.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-02 at 12:54 +0900, KUROSAWA Takahiro wrote:
> On Wed, 01 Feb 2006 17:26:00 -0800
> chandra seetharaman <sekharan@us.ibm.com> wrote:
> 
> > > >  - what is the plan to support "limit" ?
> > > 
> > > To be honest, I don't have any specific idea to support "limit" currently.
> > > Probably the userspace daemon that enlarge "guarantee" to the specified
> > > "limit" might support the "limit", because "guarantee" in the pzone based 
> > > memory resource controller also works as "limit".
> > 
> > I am not able to visualize how this will work.
> > 
> > In simple terms, sum of guarantees should _not_ exceed the amount of
> > available memory but, sum of limits _can_ exceed the amount of available
> > memory. As far as i understand your implementation, guarantee is
> > translated to present_pages of the pseudo zone (and is subtracted from
> > paren't present_pages). How can one set limit to be same as guarantee ?
> 
> The number of pages in the pseudo zones can also be considered as limit
> because tasks in a class can't allocate beyond the number of the pages
> that are allocated to the pseudo zones.  

Yes. but, it is true only when limit and guarantee are the same.

Consider the following scenario:
 A system with 1024MB of memory.

I want to create 6 classes:
 - 4 of which has guarantee of 128MB and limit of 512MB
 - 2 of which has guarantee of 256MB and limit of 768MB

We cannot do this with this memrc. Can you explain how a userspace
program can help me do this.

thanks,

chandra 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
