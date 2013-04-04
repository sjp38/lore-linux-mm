Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 917FB6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 15:07:10 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 15:07:09 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D48CF38C8069
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 15:07:05 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34J75L1320716
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 15:07:05 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34J75DA013103
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 16:07:05 -0300
Message-ID: <515DCF54.6040302@linux.vnet.ibm.com>
Date: Thu, 04 Apr 2013 12:07:00 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/24] DNUMA: Runtime NUMA memory layout reconfiguration
References: <20130228024112.GA24970@negative> <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com> <515D0F8E.7020906@gmail.com>
In-Reply-To: <515D0F8E.7020906@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>

On 04/03/2013 10:28 PM, Simon Jeons wrote:
> Hi Cody,
> On 03/01/2013 04:44 AM, Cody P Schafer wrote:
>> Some people asked me to send the email patches for this instead of
>> just posting a git tree link
>>
>> For reference, this is the original message:
>>     http://lkml.org/lkml/2013/2/27/374
>
> Could you show me your test codes?
>

Sure, I linked to it in the original email

 >	https://raw.github.com/jmesmon/trifles/master/bin/dnuma-test

I generally run something like `dnuma-test s 1 3 512`, which creates 
stripes with size='512 pages' and distributes them between nodes 1, 2, 
and 3.

Also, this patchset has some major issues (not updating the watermarks, 
for example). I've been working on ironing them out, and plan on sending 
another patchset out "soon". Current tree is 
https://github.com/jmesmon/linux/tree/dnuma/v31 (keep in mind that this 
has a few commits in it that I just use for development).

>> --
>>
>>   arch/x86/Kconfig                 |   1 -
>>   arch/x86/include/asm/sparsemem.h |   4 +-
>>   arch/x86/mm/numa.c               |  32 +++-
>>   include/linux/dnuma.h            |  96 +++++++++++
>>   include/linux/memlayout.h        | 111 +++++++++++++
>>   include/linux/memory_hotplug.h   |   4 +
>>   include/linux/mm.h               |   7 +-
>>   include/linux/page-flags.h       |  18 ++
>>   include/linux/rbtree.h           |  11 ++
>>   init/main.c                      |   2 +
>>   lib/rbtree.c                     |  40 +++++
>>   mm/Kconfig                       |  44 +++++
>>   mm/Makefile                      |   2 +
>>   mm/dnuma.c                       | 351
>> +++++++++++++++++++++++++++++++++++++++
>>   mm/internal.h                    |  13 +-
>>   mm/memlayout-debugfs.c           | 323
>> +++++++++++++++++++++++++++++++++++
>>   mm/memlayout-debugfs.h           |  35 ++++
>>   mm/memlayout.c                   | 267 +++++++++++++++++++++++++++++
>>   mm/memory_hotplug.c              |  53 +++---
>>   mm/page_alloc.c                  | 112 +++++++++++--
>>   20 files changed, 1486 insertions(+), 40 deletions(-)
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
