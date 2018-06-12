Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 855856B000A
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 06:28:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p16-v6so7708343pfn.7
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:28:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u187-v6sor115866pgc.267.2018.06.12.03.28.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 03:28:50 -0700 (PDT)
Subject: Re: [powerpc/powervm]kernel BUG at mm/memory_hotplug.c:1864!
References: <6826dab0e4382380db8d11b047272bda@linux.vnet.ibm.com>
 <20180608112823.GA20395@techadventures.net>
 <3d1e7740df56ed35c8b56941acdb7079@linux.vnet.ibm.com>
 <20180608121553.GA20774@techadventures.net>
 <0aac625ee724d877b87c69bba5ac9a0e@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <605b4df2-4cf1-2dda-3661-68b78845f8ec@gmail.com>
Date: Tue, 12 Jun 2018 20:28:43 +1000
MIME-Version: 1.0
In-Reply-To: <0aac625ee724d877b87c69bba5ac9a0e@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vrbagal1 <vrbagal1@linux.vnet.ibm.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: sachinp <sachinp@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, nfont@linux.vnet.ibm.com, Linuxppc-dev <linuxppc-dev-bounces+vrbagal1=linux.vnet.ibm.com@lists.ozlabs.org>, linux-next <linux-next@vger.kernel.org>



On 11/06/18 17:41, vrbagal1 wrote:
> On 2018-06-08 17:45, Oscar Salvador wrote:
>> On Fri, Jun 08, 2018 at 05:11:24PM +0530, vrbagal1 wrote:
>>> On 2018-06-08 16:58, Oscar Salvador wrote:
>>> >On Fri, Jun 08, 2018 at 04:44:24PM +0530, vrbagal1 wrote:
>>> >>Greetings!!!
>>> >>
>>> >>I am seeing kernel bug followed by oops message and system reboots,
>>> >>while
>>> >>running dlpar memory hotplug test.
>>> >>
>>> >>Machine Details: Power6 PowerVM Platform
>>> >>GCC version: (gcc version 4.8.3 20140911 (Red Hat 4.8.3-7) (GCC))
>>> >>Test case: dlpar memory hotplug test (https://github.com/avocado-framework-tests/avocado-misc-tests/blob/master/memory/memhotplug.py)
>>> >>Kernel Version: Linux version 4.17.0-autotest
>>> >>
>>> >>I am seeing this bug on rc7 as well.
> 
> Observing similar traces on linux next kernel: 4.17.0-next-20180608-autotest
> 
> A Block size [0x4000000] unaligned hotplug range: start 0x220000000, size 0x1000000

size < block_size in this case, why? how? Could you confirm that the block size is 64MB and your trying to remove 16MB

Balbir Singh.
