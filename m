Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7R2X4Du015175
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 12:33:04 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7R2WGo7272440
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 12:32:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7R2WG7u005958
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 12:32:16 +1000
Message-ID: <48B4BCAE.7000906@linux.vnet.ibm.com>
Date: Wed, 27 Aug 2008 08:02:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B3E4CC.9060309@linux.vnet.ibm.com> <48B3F04B.9030308@iplabs.de> <48B401F8.9010703@linux.vnet.ibm.com> <48B402B1.8030902@linux.vnet.ibm.com> <1219777788.24829.53.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1219777788.24829.53.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: Marco Nietz <m.nietz-mm@iplabs.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Larry Woodman wrote:
> On Tue, 2008-08-26 at 18:48 +0530, Balbir Singh wrote:
>> Balbir Singh wrote:
>>
>> Looking closely, may be there is a leak like Christoph suggested (most of the
>> pages have been consumed by the kernel) - only 280kB+244kB is in use by user
>> pages. The rest has either leaked or in use by the kernel.
>>
> 
> There is no leak.  Between the ptepages(pagetables:152485), the
> memmap(4456448 pages of RAM * 32bytes = 34816 pages) and the
> slabcache(slab:35543) you can account for ~99% of the Normal zone and
> its wired.  You simply cant run a large database without hugepages and
> without CONFIG_HIGHPTE set and not exhaust Lowmem on a 16GB x86 system.

Thanks for looking at it more closely, Yes, we do need to have CONFIG_HIGHPTE
enabled.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
