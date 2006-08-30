Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7UID6R7003284
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 14:13:06 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UID6ka263332
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 14:13:06 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UID6t8032111
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 14:13:06 -0400
Subject: Re: libnuma interleaving oddness
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <eada2a070608301101j205b2711va5c287dbf8aab492@mail.gmail.com>
References: <20060829231545.GY5195@us.ibm.com>
	 <200608300919.13125.ak@suse.de> <20060830072948.GE5195@us.ibm.com>
	 <200608300932.23746.ak@suse.de>
	 <eada2a070608301101j205b2711va5c287dbf8aab492@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 30 Aug 2006 13:13:05 -0500
Message-Id: <1156961585.7185.8680.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Pepper <tpepper@gmail.com>
Cc: Andi Kleen <ak@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-30 at 11:01 -0700, Tim Pepper wrote:
> On 8/30/06, Andi Kleen <ak@suse.de> wrote:
> > Then it's probably some new problem in hugetlbfs.
> 
> It's something subtle though, because I _am_ able to get interleaving
> on hugetlbfs with a slightly simplified test case (see previous email)
> compared to Nish's.
> 
> > Does it work with shmfs?
> 
> Haven't tried shmfs, but the following correctly does the expected
> interleaving with hugepages (although not hugetlbfs backed):
>      shmid = shmget( 0, NR_HUGE_PAGES, IPC_CREAT | SHM_HUGETLB | 0666 );
>      shmat_addr = shmat( shmid, NULL, 0 );
>      ...
>      numa_interleave_memory( shmat_addr, SHM_SIZE, &nm );
> I'd expect it works fine with non-huge pages, shmfs.

Actually, the above call will yield hugetlbfs backed huge pages.  The
kernel just prepares the hugetlbfs file for you.  See
hugetlb_zero_setup().

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
