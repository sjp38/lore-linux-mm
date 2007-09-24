Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ONTOZq028094
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 19:29:24 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ONTOuS684442
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 19:29:24 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ONTN6h021694
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 19:29:24 -0400
Date: Mon, 24 Sep 2007 16:29:22 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
Message-ID: <20070924232922.GF26104@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com> <20070906182704.GC7779@us.ibm.com> <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com> <1189796638.5315.50.camel@localhost> <Pine.LNX.4.64.0709141241050.17369@schroedinger.engr.sgi.com> <1189800591.5315.69.camel@localhost> <Pine.LNX.4.64.0709141315510.22157@schroedinger.engr.sgi.com> <1189801980.5315.87.camel@localhost> <20070924232346.GE26104@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070924232346.GE26104@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.09.2007 [16:23:46 -0700], Nishanth Aravamudan wrote:
> On 14.09.2007 [16:33:00 -0400], Lee Schermerhorn wrote:
> > On Fri, 2007-09-14 at 13:16 -0700, Christoph Lameter wrote:
> > > On Fri, 14 Sep 2007, Lee Schermerhorn wrote:
> > > 
> > > > Yeah, I mistyped...  But, nid IS private to that function.  This is a
> > > > valid use of static.  But, perhaps it could use a comment to call
> > > > attention to it.
> > > 
> > > I think its best to move nis outside of the function and give it a longer 
> > > name that is distinctive from names we use for local variables. F.e.
> > > 
> > > last_allocated_node
> > > 
> > > ?
> > 
> > I do like to see variables' [and functions'] visibility kept within
> > the minimum necessary scope, and moving it outside of the function
> > violates this.  Nothing else in the source file needs it.  But, If
> > Nish agrees, I guess I don't feel that strongly about it.  I like the
> > suggested name, tho'
> 
> I've changed the name, but I don't see how moving the scope helps. I
> guess I could it make it globally static -- as opposed to local to the
> function -- and then it would be easier to dequeue based upon the
> global's value (something Lee asked for earlier). However, that would
> require locking to avoid races between two processes both echo'ing
> values into the sysctl? I guess it's not a serious race with the sanity
> check that Andrew has in there, it just means sometimes a node might get
> skipped in the interleaving...

err, not skipped, but allocated to twice. Then again, we already have a
comment to that effect now. So I'll go ahead and test this out.

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
