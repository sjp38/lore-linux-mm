Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3A56B029E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:10:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu14so135384321pad.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:10:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id af8si13965254pad.16.2016.09.29.04.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 04:10:28 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8TB97X2008182
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:10:27 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25s1339w7g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:10:27 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 29 Sep 2016 05:10:27 -0600
Date: Thu, 29 Sep 2016 04:10:23 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Soft lockup in __slab_free (SLUB)
Reply-To: paulmck@linux.vnet.ibm.com
References: <57E8D270.8040802@kyup.com>
 <20160928053114.GC22706@js1304-P5Q-DELUXE>
 <57EB6DF5.2010503@kyup.com>
 <20160929014024.GA29250@js1304-P5Q-DELUXE>
 <20160929021100.GI14933@linux.vnet.ibm.com>
 <20160929025559.GE29250@js1304-P5Q-DELUXE>
 <57ECBE8D.6000703@kyup.com>
 <20160929102743.GL14933@linux.vnet.ibm.com>
 <57ECF1FA.6010908@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57ECF1FA.6010908@kyup.com>
Message-Id: <20160929111023.GO14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, brouer@redhat.com

On Thu, Sep 29, 2016 at 01:50:34PM +0300, Nikolay Borisov wrote:
> 
> 
> On 09/29/2016 01:27 PM, Paul E. McKenney wrote:
> > On Thu, Sep 29, 2016 at 10:11:09AM +0300, Nikolay Borisov wrote:
> [SNIP]
> 
> >> What in particular should I be looking for in ftrace? tracing the stacks
> >> on the stuck cpu?
> > 
> > To start with, how about the sequence of functions that the stuck
> > CPU is executing?
> 
> Unfortunately I do not know how to reproduce the issue, but it is being
> reproduced byt our production load - which is creating backups in this
> case. They are created by rsyncing files to a loop-back attached files
> wihch are then unmounted and unmapped.From this crash it is evident that
> the hang occurs while a volume is being unmounted.
> 
> But the callstack is in my hang report, no? I have the crashdump with me
> so if you are interested in anything in particular I can go look for it.
> I believe an inode eviction was requested, since destroy_inode, which
> utilizes ext4_i_callback is called in the eviction + some errors paths.
> And this eviction is executed on this particular CPU. What in particular
> are you looking for?
> 
> Unfortunately it's impossible for me to run:
> 
> trace-cmd record -p function_graph -F <command that causes the issue>

Given that the hang appears to involve a few common functions, is it
possible to turn ftrace on for those functions (and related ones) at boot
time?  Or using sysfs just after boot time?

Given that you cannot reproduce at will, your earlier suggestion of enabling
tracing of stacks might also make a lot of sense.

							Thanx, Paul

> [SNIP]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
