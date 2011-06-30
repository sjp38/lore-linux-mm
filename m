Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D25286B0083
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 01:11:37 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5U5BPFe015239
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:41:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5U5BPvC3977222
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:41:25 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5U5BOjd024174
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:41:24 +0530
Date: Thu, 30 Jun 2011 10:41:23 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110630051123.GD12667@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110629130038.GA7909@in.ibm.com>
 <1309367184.11430.594.camel@nimitz>
 <20110629174220.GA9152@in.ibm.com>
 <1309370342.11430.604.camel@nimitz>
 <m2y60k1jqj.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2y60k1jqj.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

Hi,

On Wed, Jun 29, 2011 at 01:11:00PM -0700, Andi Kleen wrote:
> Dave Hansen <dave@linux.vnet.ibm.com> writes:
> >
> > It's also going to be a pain to track kernel references.  On x86, our
> 

As Vaidy mentioned, we are only looking at memory being either allocated
or free, as a way to evacuate it. Tracking memory references, no doubt,
is a difficult proposition and might involve a lot of overhead.
 
> Even if you tracked them what would you do with them?
>
> It's quite hard to stop using arbitary kernel memory (see all the dancing
> memory-failure does) 
> 
> You need to track the direct accesses to user data which happens
> to be accessed through the direct mapping.
> 
> Also it will be always unreliable because this all won't track DMA.
> For that you would also need to track in the dma_* infrastructure,
> which will likely get seriously expensive.
> 

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
