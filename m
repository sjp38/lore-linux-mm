Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDJL0CR020568
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:21:00 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDJKvQG1335330
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:20:57 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDJKcPk029178
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:20:39 -0700
Date: Thu, 13 Dec 2007 11:20:08 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 3/3] Documetation: update hugetlb information
Message-ID: <20071213192008.GH17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com> <1197562629.21438.20.camel@localhost> <20071213164453.GC17526@us.ibm.com> <1197565364.21438.23.camel@localhost> <20071213180116.GF17526@us.ibm.com> <1197572668.21438.34.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1197572668.21438.34.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.12.2007 [11:04:28 -0800], Dave Hansen wrote:
> On Thu, 2007-12-13 at 10:01 -0800, Nishanth Aravamudan wrote:
> > +Caveat: Shrinking the pool via nr_hugepages while a surplus is in effect
> > +will allow the number of surplus huge pages to exceed the overcommit
> > +value, as the pool hugepages (which must have been in use for a surplus
> > +hugepages to be allocated) will become surplus hugepages.  As long as
> > +this condition holds, however, no more surplus huge pages will be
> > +allowed on the system until one of the two sysctls are increased
> > +sufficiently, or the surplus huge pages go out of use and are freed.
> 
> I guess you could, in theory, disallow the writes to the sysctl and
> return -EINVAL or -ENOSPC or something.  But, I think documenting it
> like this is probably OK by itself and is pretty sane behavior given
> the circumstances.  

That's true -- would complicate the sysctl callback which is currently
able to just use one of the generic functions.

I'm willing to investigate changing this, if there is interest.

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
