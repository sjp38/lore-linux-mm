Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0GJw8Ov003123
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 14:58:08 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GJw7Gr088388
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 14:58:07 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GJw6gj017314
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 14:58:07 -0500
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <200712121640.17077.nickpiggin@yahoo.com.au>
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <200712121557.20807.nickpiggin@yahoo.com.au>
	 <1197436306.6367.12.camel@norville.austin.ibm.com>
	 <200712121640.17077.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 16 Jan 2008 13:58:02 -0600
Message-Id: <1200513482.6935.15.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, Adam Litke <agl@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-12 at 16:40 +1100, Nick Piggin wrote:
> On Wednesday 12 December 2007 16:11, Dave Kleikamp wrote:
> > On Wed, 2007-12-12 at 15:57 +1100, Nick Piggin wrote:

> > > Anyway, I am hoping that someone will one day and test if this and
> > > find it helps their workload, but on the other hand, if it doesn't
> > > help anyone then we don't have to worry about adding it to the
> > > kernel ;) I don't have any real setups that hammers DIO with threads.
> > > I'm guessing DB2 and/or Oracle does?
> >
> > I'll try to get someone to run a DB2 benchmark and see what it looks
> > like.
> 
> That would be great if you could.

We weren't able to get in any runs before the holidays, but we finally
have some good news from our performance team:

"To test the effects of the patch, an OLTP workload was run on an IBM
x3850 M2 server with 2 processors (quad-core Intel Xeon processors at
2.93 GHz) using IBM DB2 v9.5 running Linux 2.6.24rc7 kernel. Comparing
runs with and without the patch resulted in an overall performance
benefit of ~9.8%. Correspondingly, oprofiles showed that samples from
__up_read and __down_read routines that is seen during thread contention
for system resources was reduced from 2.8% down to .05%. Monitoring
the /proc/vmstat output from the patched run showed that the counter for
fast_gup contained a very high number while the fast_gup_slow value was
zero."

Great work, Nick!

Thanks,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
