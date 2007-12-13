Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDJ4mMF031783
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:04:48 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDJ4UOG299780
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:04:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDJ4UOX014970
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:04:30 -0500
Subject: Re: [RFC][PATCH 3/3] Documetation: update hugetlb information
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071213180116.GF17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
	 <1197562629.21438.20.camel@localhost> <20071213164453.GC17526@us.ibm.com>
	 <1197565364.21438.23.camel@localhost>  <20071213180116.GF17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 11:04:28 -0800
Message-Id: <1197572668.21438.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-13 at 10:01 -0800, Nishanth Aravamudan wrote:
> +Caveat: Shrinking the pool via nr_hugepages while a surplus is in effect
> +will allow the number of surplus huge pages to exceed the overcommit
> +value, as the pool hugepages (which must have been in use for a surplus
> +hugepages to be allocated) will become surplus hugepages.  As long as
> +this condition holds, however, no more surplus huge pages will be
> +allowed on the system until one of the two sysctls are increased
> +sufficiently, or the surplus huge pages go out of use and are freed.

I guess you could, in theory, disallow the writes to the sysctl and
return -EINVAL or -ENOSPC or something.  But, I think documenting it
like this is probably OK by itself and is pretty sane behavior given the
circumstances.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
