Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m0A4Dfel012875
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 15:13:41 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0A4E7WV2478182
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 15:14:07 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0A4DpWH022308
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 15:13:51 +1100
Date: Thu, 10 Jan 2008 09:43:02 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080110041302.GA8271@skywalker>
References: <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com> <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com> <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 11:23:59AM -0800, Christoph Lameter wrote:
> On Thu, 10 Jan 2008, Aneesh Kumar K.V wrote:
> 
> > kernel BUG at mm/slab.c:3323!
> 
> That is 
> 
>         l3 = cachep->nodelists[nodeid];
>         BUG_ON(!l3);
> 
> retry:
>         check_irq_off();
>         ^^^^ this statment?
> 
> or the BUG_ON(!l3)?
> 

3320         int x;
3321 
3322         l3 = cachep->nodelists[nodeid];
3323         BUG_ON(!l3);
3324 
3325 retry:
3326         check_irq_off();

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
