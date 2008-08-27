Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx.iplabs.de (Postfix) with ESMTP id 001FA240537A
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 08:21:37 +0200 (CEST)
Received: from mx.iplabs.de ([127.0.0.1])
	by localhost (osiris.iplabs.de [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 7hgrCKetmC+y for <linux-mm@kvack.org>;
	Wed, 27 Aug 2008 08:21:29 +0200 (CEST)
Received: from [172.16.1.1] (mnietz.client.iplabs.de [172.16.1.1])
	by mx.iplabs.de (Postfix) with ESMTP id 0EBBD2405379
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 08:21:29 +0200 (CEST)
Message-ID: <48B4F268.20901@iplabs.de>
Date: Wed, 27 Aug 2008 08:21:28 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B3E4CC.9060309@linux.vnet.ibm.com> <48B3F04B.9030308@iplabs.de> <48B401F8.9010703@linux.vnet.ibm.com> <48B402B1.8030902@linux.vnet.ibm.com> <1219777788.24829.53.camel@dhcp-100-19-198.bos.redhat.com> <48B4BCAE.7000906@linux.vnet.ibm.com>
In-Reply-To: <48B4BCAE.7000906@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thank you all for your Help.

My first guess that the oom where caused by running out of Lowmem was
confirmed and the Solution is to upgrade the Server to a 64bit OS.

All right to that point, but why this was affected by the raised up
Sharded Buffers from postgres ? Is shared buffer preferred to be in lowmem ?

With the smaller Buffersize (256mb) we haven't had any Problems with
that Machine.

> Larry Woodman wrote:
>> On Tue, 2008-08-26 at 18:48 +0530, Balbir Singh wrote:
>>> Balbir Singh wrote:
>>>
>>> Looking closely, may be there is a leak like Christoph suggested (most of the
>>> pages have been consumed by the kernel) - only 280kB+244kB is in use by user
>>> pages. The rest has either leaked or in use by the kernel.
>>>
>> There is no leak.  Between the ptepages(pagetables:152485), the
>> memmap(4456448 pages of RAM * 32bytes = 34816 pages) and the
>> slabcache(slab:35543) you can account for ~99% of the Normal zone and
>> its wired.  You simply cant run a large database without hugepages and
>> without CONFIG_HIGHPTE set and not exhaust Lowmem on a 16GB x86 system.
> 
> Thanks for looking at it more closely, Yes, we do need to have CONFIG_HIGHPTE
> enabled.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
