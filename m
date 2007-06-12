Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C2kYX7006595
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:46:34 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2kYlw558934
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:46:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2kXBq002290
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:46:34 -0400
Date: Mon, 11 Jun 2007 19:46:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
Message-ID: <20070612024631.GO3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <20070612112757.e2d511e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612112757.e2d511e0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [11:27:57 +0900], KAMEZAWA Hiroyuki wrote:
> On Mon, 11 Jun 2007 13:27:28 -0700
> Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > Split up Lee and Anton's original patch
> > (http://marc.info/?l=linux-mm&m=118133042025995&w=2), to allow for the
> > populated_map changes to go in on their own.
> > 
> > Add a populated_map nodemask to indicate a node has memory or not. We
> > have run into a number of issues (in practice and in code) with
> > assumptions about every node having memory. Having this nodemask allows
> > us to fix these issues; in particular, THISNODE allocations will come
> > from the node specified, only, and the INTERLEAVE policy will be able to
> > do the right thing with memoryless nodes.
> > 
> Thank you, I like this work.

Thanks, I hope it is useful :)

> > +extern nodemask_t node_populated_map;
> please add /* node has memory */ here.
> 
> I don't think "populated node" means "node-with-memory" if there is no comments.

Good point, I'll send a small diff for Andrew to pick up when I refresh
the other patches tomorrow.

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
