Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NIsNkx024283
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:54:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NIsMBK311640
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:54:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NIsM8l007933
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:54:22 -0400
Date: Wed, 23 Apr 2008 11:54:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB
	hugetlb for x86
Message-ID: <20080423185421.GF10548@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org> <20080423155338.GF16769@wotan.suse.de> <20080423160210.GC29087@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423160210.GC29087@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [18:02:10 +0200], Andi Kleen wrote:
> > No, it can generally determine the size of the hugepages. It would
> > be more wrong (but probably more common) for portable code to assume
> 
> For compatibility we have to assume code does that.
> 
> > 2MB hugepages.
> 
> Well then it should just run with 2MB pages on a kernel where both
> 1G and 2M are configured. Does it not do that? 
> 
> > If you want your legacy userspace to have 2MB hugepages, then you would
> 
> I think all legacy user space should only use 2MB huge pages.

Even with what you're saying (that 1G implies 2M is also there), let's
say a legacy app just looks in /proc/mounts for hugetlbfs mountpoints
and then creates a file in the first one it finds. If the system
administrator mounted a 1G hugetlbfs first, then the legacy app is going
to get 1G pages, regardless of whether or not 2M are presented to
userspace. So that legacy app just broke -- I don't see any way of
preventing that.

I think Nick's method is sane and reasonable. Do you know of specific
legacy apps that require what you're saying?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
