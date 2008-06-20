Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5K3IQSE029717
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 23:18:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5K3IPKh122866
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 21:18:25 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5K3IPXe009664
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 21:18:25 -0600
Message-ID: <485B2180.10507@us.ibm.com>
Date: Thu, 19 Jun 2008 22:18:24 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: 2.6.26-rc5-mm3: BUG large value for HugePages_Rsvd
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A8903.9030808@linux.vnet.ibm.com> <20080619171644.GC13275@shadowen.org>
In-Reply-To: <20080619171644.GC13275@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> On Thu, Jun 19, 2008 at 11:27:47AM -0500, Jon Tollefson wrote:
>   
>> After running some of the libhugetlbfs tests the value for
>> /proc/meminfo/HugePages_Rsvd becomes really large.  It looks like it has
>> wrapped backwards from zero.
>> Below is the sequence I used to run one of the tests that causes this;
>> the tests passes for what it is intended to test but leaves a large
>> value for reserved pages and that seemed strange to me.
>> test run on ppc64 with 16M huge pages
>>     
>
> Yes Adam reported that here yesterday, he found it in his hugetlfs testing.
> I have done some investigation on it and it is being triggered by a bug in
> the private reservation tracking patches.  It is triggered by the hugetlb
> test which causes some complex vma splits to occur on a private mapping.
>   
sorry I missed that

> I believe I have the underlying problem nailed and do have some nearly
> complete patches for this and they should be in a postable state by
> tommorrow.
>   
Cool.
> -apw
>   
Jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
