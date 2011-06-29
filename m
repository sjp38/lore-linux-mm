Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CA15B6B00E7
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 14:18:06 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5TII1eM012264
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:48:01 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5TII1QD3989650
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:48:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5TII0iU018382
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 04:18:01 +1000
Date: Wed, 29 Jun 2011 23:47:55 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110629181755.GG3646@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110629130038.GA7909@in.ibm.com>
 <1309367184.11430.594.camel@nimitz>
 <20110629174220.GA9152@in.ibm.com>
 <1309370342.11430.604.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1309370342.11430.604.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

* Dave Hansen <dave@linux.vnet.ibm.com> [2011-06-29 10:59:02]:

> On Wed, 2011-06-29 at 23:12 +0530, Ankita Garg wrote:
> > 	4. The kernel must have a mechanism to maintain utilization
> > 	   statistics pertaining to a piece of hardware, so that it can
> > 	   trigger the hardware to power it off
> 
> Having statistics like this would certainly be nice, but how important
> _is_ it?  Is it really a show-stopper?  There's some stuff today, like
> the NPT/EPT support in KVM where we don't even have visibility in to
> when a given page is referenced.
> 
> It's also going to be a pain to track kernel references.  On x86, our
> kernel linear mapping uses 1GB pages when it can, and those are greater
> than the 512MB granularity that we've been talking about here.  It's
> even larger on powerpc.  I'm also pretty sure we don't even _look_ at
> the referenced bits in the kernel page tables.  We'll definitely need
> some infrastructure to do that.

Utilization is all about allocated vs free and at most 'type of
allocation'.  We are not looking at actual reference rates from page
tables.  A free or unallocated page is not going to be referenced.


> > 	5. Being able to group these pieces of hardware for purpose of
> > 	   higher savings. 
> 
> Do you really mean group, or do you mean "turn as many off as possible"?

Grouping based on hardware topology could help save more power at
higher granularity.  In most cases just turning as many off as
possible will work.  But the design should allow grouping based on
certain rules or hierarchies.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
