Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFC4D6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:37:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id w130so43198174iow.3
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:37:29 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id g17si7915750ita.71.2017.04.10.07.37.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 07:37:29 -0700 (PDT)
Message-ID: <58EB97D4.1040605@huawei.com>
Date: Mon, 10 Apr 2017 22:33:56 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: NULL pointer dereference in the kernel 3.10
References: <58E8E81E.6090304@huawei.com> <20170410085604.zpenj6ggc3dsbgxw@techsingularity.net> <58EB761E.9040002@huawei.com> <20170410124814.GC4618@dhcp22.suse.cz> <58EB9183.2030806@huawei.com> <20170410141321.GB8008@1wt.eu>
In-Reply-To: <20170410141321.GB8008@1wt.eu>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, Vlastimil Babka <vbabka@suse.cz>, Linux Memory
 Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/4/10 22:13, Willy Tarreau wrote:
> On Mon, Apr 10, 2017 at 10:06:59PM +0800, zhong jiang wrote:
>> On 2017/4/10 20:48, Michal Hocko wrote:
>>> On Mon 10-04-17 20:10:06, zhong jiang wrote:
>>>> On 2017/4/10 16:56, Mel Gorman wrote:
>>>>> On Sat, Apr 08, 2017 at 09:39:42PM +0800, zhong jiang wrote:
>>>>>> when runing the stabile docker cases in the vm.   The following issue will come up.
>>>>>>
>>>>>> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
>>>>>>     [exception RIP: down_read_trylock+5]
>>>>>>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
>>>>>>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
>>>>>>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
>>>>>>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
>>>>>>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
>>>>>>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
>>>>>>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>>>>> Post the full report including the kernel version and state whether any
>>>>> additional patches to 3.10 are applied.
>>>>>
>>>>  Hi, Mel
>>>>    
>>>>         Our kernel from RHEL 7.2, Addtional patches all from upstream -- include Bugfix and CVE.
>>> I believe you should contact Redhat for the support. This is a) old
>>> kernel and b) with other patches which might or might not be relevant.
>>   Ok, regardless of the kernel version, we just discuss the situation in theory.  if commit
>>   624483f3ea8  ("mm: rmap: fix use-after-free in __put_anon_vma")  is not exist. the issue
>>  will trigger . Any thought.
> But this commit was backported into 3.10.43, so stable kernel users are safe.
>
> Regards,
> Willy
>
> .
  yes,  you are sure that the commit can fix the issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
