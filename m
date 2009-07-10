Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 249B16B006A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:25:57 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6A6pkD9003710
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:51:46 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6A6mTPC253194
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:48:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6A6jvv1016239
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:45:58 -0400
Date: Fri, 10 Jul 2009 12:18:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] Memory controller soft limit documentation
	(v8)
Message-ID: <20090710064826.GB20129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop> <20090709171449.8080.40970.sendpatchset@balbir-laptop> <20090710143216.7f5dc6b8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090710143216.7f5dc6b8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:32:16]:

> On Thu, 09 Jul 2009 22:44:49 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Feature: Add documentation for soft limits
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> > 
> >  Documentation/cgroups/memory.txt |   31 ++++++++++++++++++++++++++++++-
> >  1 files changed, 30 insertions(+), 1 deletions(-)
> > 
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index ab0a021..b47815c 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -379,7 +379,36 @@ cgroups created below it.
> >  
> >  NOTE2: This feature can be enabled/disabled per subtree.
> >  
> > -7. TODO
> > +7. Soft limits
> > +
> > +Soft limits allow for greater sharing of memory. The idea behind soft limits
> > +is to allow control groups to use as much of the memory as needed, provided
> > +
> > +a. There is no memory contention
> > +b. They do not exceed their hard limit
> > +
> > +When the system detects memory contention or low memory control groups
> > +are pushed back to their soft limits. If the soft limit of each control
> > +group is very high, they are pushed back as much as possible to make
> > +sure that one control group does not starve the others of memory.
> > +
> 
> It's better to write "this is best-effort service". We add hook only to kswapd.
> And hou successfull this work depends on ZONE.
>

Will do, Thanks for the review. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
