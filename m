Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m095leRr021732
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 00:47:40 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m096oH5e134814
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 23:50:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m096oHcR000321
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 23:50:17 -0700
Date: Tue, 8 Jan 2008 22:50:15 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080109065015.GG7602@us.ibm.com>
References: <20071225140519.ef8457ff.akpm@linux-foundation.org> <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com> <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On 07.01.2008 [21:38:51 -0800], Christoph Lameter wrote:
> On Tue, 8 Jan 2008, KAMEZAWA Hiroyuki wrote:
> 
> > In usual alloc_pages() allocator, this is done by zonelist fallback.
> 
> Hmmm... __cache_alloc_node does:
> 
>     if (unlikely(!cachep->nodelists[nodeid])) {
>                 /* Node not bootstrapped yet */
>                 ptr = fallback_alloc(cachep, flags);
>                 goto out;
>         }
> 
> So kmalloc_node does the correct fallback.
> 
> Kmalloc does not fall back but relies on numa_node_id() referring to a 
> node that has ZONE_NORMAL memory. Sigh.

Do we (perhaps you already have done so, Christoph), want to validate
any other users of numa_node_id() that then make assumptions about the
characteristics of the nid? Hrm, that sounds good in theory, but seems
hard in practice?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
