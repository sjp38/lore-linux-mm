Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E377C9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 00:54:47 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p674sQOk013182
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 14:54:26 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p674sQIk1228892
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 14:54:26 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p674sQ0K007255
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 14:54:26 +1000
Date: Thu, 7 Jul 2011 10:24:20 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110707045420.GA23595@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110629130038.GA7909@in.ibm.com>
 <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
 <alpine.DEB.2.02.1107061318190.2535@asgard.lang.hm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1107061318190.2535@asgard.lang.hm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@lang.hm
Cc: Pekka Enberg <penberg@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Lameter <cl@linux.com>

On Wed, Jul 06, 2011 at 01:20:55PM -0700, david@lang.hm wrote:
> On Wed, 6 Jul 2011, Pekka Enberg wrote:
> 
> >Why does the allocator need to know about address boundaries? Why
> >isn't it enough to make the page allocator and reclaim policies favor using
> >memory from lower addresses as aggressively as possible? That'd mean
> >we'd favor the first memory banks and could keep the remaining ones
> >powered off as much as possible.
> >
> >IOW, why do we need to support scenarios such as this:
> >
> >  bank 0     bank 1   bank 2    bank3
> >| online  | offline | online  | offline |
> 
> I believe that there are memory allocations that cannot be moved
> after they are made (think about regions allocated to DMA from
> hardware where the hardware has already been given the address space
> to DMA into)
>

Thats true. These are kernel allocations which are not movable. However,
the ZONE_MOVABLE would enable us to create complete movable zones and
the ones that have the kernel allocations could be flagged as kernelcore
zone.
 
> As a result, you may not be able to take bank 2 offline, so your
> option is to either leave banks 0-2 all online, or support emptying
> bank 1 and taking it offline.
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
