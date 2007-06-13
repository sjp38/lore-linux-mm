Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DNuQcU032465
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:56:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DNuQC9194568
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:56:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DNuQri002659
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:56:26 -0600
Date: Wed, 13 Jun 2007 16:56:24 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070613235624.GA3798@us.ibm.com>
References: <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com> <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost> <20070613175802.GP3798@us.ibm.com> <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com> <20070613230906.GV3798@us.ibm.com> <Pine.LNX.4.64.0706131609370.394@schroedinger.engr.sgi.com> <20070613231825.GX3798@us.ibm.com> <Pine.LNX.4.64.0706131625530.698@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131625530.698@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [16:26:15 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Well...maybe we can do better by just adding another GFP flag?
> > 
> > GFP_ONLYTHISNODE?
> > 
> > THISNODE has the current semantics, that the "closest" node is
> > preferred, which may be local, and it will succeed if memory exists
> > somewhere for the allocation you want (I think).
> 
> No we want one GFP_THISNODE working in a consistent way.

Ok, I've started auditing things. I have a final exam tomorrow, however,
so probably won't make much progress before then.

I did notice that ia64/mm/discontig.c actually already tries to deal
with memoryless nodes, but all static to that file. See
memory_less_mask. Probably can be replaced via an inverted
node_memory_map.

Are you sure just the VM needs to be audited? I'm going to try the other
way around and look at GFP_THISNODE callers and go up from there.

Will let you know what I find.

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
