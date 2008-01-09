Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09MDHGt027814
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 17:13:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09MDHjB329506
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 17:13:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09MDGtG008328
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 17:13:17 -0500
Date: Wed, 9 Jan 2008 14:13:15 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080109221315.GB26941@us.ibm.com>
References: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com> <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com> <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com> <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On 09.01.2008 [13:51:42 -0800], Christoph Lameter wrote:
> On Wed, 9 Jan 2008, Nishanth Aravamudan wrote:
> 
> > And given that the original mail has bug at mm/slab.c:3320, I assume we're
> > still hitting the
> > 
> > BUG_ON(ac->avail > 0 || !l3);
> 
> No we are in a different function here.

Ah you're right -- sorry for the noise.

> > Hrm, shouldn't we remove the !l3 bit from the BUG_ON? But even so,
> > unless for some reason the BUG_ON is being checked before the if
> > (!l3), are we hitting (ac->avail > 0)?
> 
> Yes we should remove the !l3 bit. There cannot be any objects in SLABs
> per cpu queue if there is no node structure. per cpu queues can only
> be refilled from the local node, not from foreign nodes. And in this
> particular case there is no memory available from the local node. So
> ac->avail == 0.

Makes sense, thanks for the clarification.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
