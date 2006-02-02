Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1227lWB031919
	for <linux-mm@kvack.org>; Wed, 1 Feb 2006 21:07:47 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1225e9M272290
	for <linux-mm@kvack.org>; Wed, 1 Feb 2006 19:05:50 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k1227aDT027347
	for <linux-mm@kvack.org>; Wed, 1 Feb 2006 19:07:36 -0700
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
	controller
From: chandra seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <20060201053958.CE35B74035@sv1.valinux.co.jp>
References: <20060119080408.24736.13148.sendpatchset@debian>
	 <20060131023000.7915.71955.sendpatchset@debian>
	 <1138762698.3938.16.camel@localhost.localdomain>
	 <20060201053958.CE35B74035@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Wed, 01 Feb 2006 17:26:00 -0800
Message-Id: <1138843560.3939.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-02-01 at 14:39 +0900, KUROSAWA Takahiro wrote:
> Chandra,
> 
> On Tue, 31 Jan 2006 18:58:18 -0800
> chandra seetharaman <sekharan@us.ibm.com> wrote:
> 
> > I like the idea of multiple controllers for a resource. Users will have
> > options to choose from. Thanks for doing it.
> 
> You are welcome.  Thanks for the comments.
> 
> > I have few questions:
> >  - how are shared pages handled ?
> 
> Shared pages are accounted to the class that a task in it allocate 
> the pages.  This behavior is different from the memory resource 
> controller in CKRM.

all others get a free access ? It may not be a good option. SHared pages
either have to be accounted separately or shared between the classes
that use them.

current memrc also charges to the class that brings the page in. Valerie
is in the process of making changes to make the shared pages belong to a
separate class.

> 
> >  - what is the plan to support "limit" ?
> 
> To be honest, I don't have any specific idea to support "limit" currently.
> Probably the userspace daemon that enlarge "guarantee" to the specified
> "limit" might support the "limit", because "guarantee" in the pzone based 
> memory resource controller also works as "limit".

I am not able to visualize how this will work.

In simple terms, sum of guarantees should _not_ exceed the amount of
available memory but, sum of limits _can_ exceed the amount of available
memory. As far as i understand your implementation, guarantee is
translated to present_pages of the pseudo zone (and is subtracted from
paren't present_pages). How can one set limit to be same as guarantee ?

> 
> >  - can you provide more information in stats ?
> 
> Ok, I'll do that.
> 
> >  - is it designed to work with cpumeter alone (i.e without ckrm) ?
> 
> Maybe it works with cpumeter.

have you tested it without ckrm (i mean only with cpumeter)
> 
> > comment/suggestion:
> >  - IMO, moving pages from a class at time of reclassification would be
> >    the right thing to do. May be we have to add a pointer to Chris patch
> >    and make sure it works as we expect.
> > 
> >  - instead of adding the pseudo zone related code to the core memory
> >    files, you can put them in a separate file.
> 
> That's right.  But I guess that several static functions in 
> mm/page_alloc.c would need to be exported.

it will be a lot cleaner.
> 
> >  - Documentation on how to configure and use it would be good.
> 
> I think so too.  I'll write some documents.
> 
> Thanks,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
