Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA74D6B02F2
	for <linux-mm@kvack.org>; Tue,  2 May 2017 04:54:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t7so55261272pgt.6
        for <linux-mm@kvack.org>; Tue, 02 May 2017 01:54:48 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id j88si16971007pfj.117.2017.05.02.01.54.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 01:54:48 -0700 (PDT)
Message-ID: <590848B0.2000801@huawei.com>
Date: Tue, 2 May 2017 16:52:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] dev/mem: "memtester -p 0x6c80000000000 10G" cause crash
References: <59083C5B.5080204@huawei.com> <20170502084323.GG14593@dhcp22.suse.cz>
In-Reply-To: <20170502084323.GG14593@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/2 16:43, Michal Hocko wrote:

> On Tue 02-05-17 15:59:23, Xishi Qiu wrote:
>> Hi, I use "memtester -p 0x6c80000000000 10G" to test physical address 0x6c80000000000
>> Because this physical address is invalid, and valid_mmap_phys_addr_range()
>> always return 1, so it causes crash.
>>
>> My question is that should the user assure the physical address is valid?
> 
> We already seem to be checking range_is_allowed(). What is your
> CONFIG_STRICT_DEVMEM setting? The code seems to be rather confusing but
> my assumption is that you better know what you are doing when mapping
> this file.
> 

HI Michal,

CONFIG_STRICT_DEVMEM=y, and range_is_allowed() will skip memory, but
0x6c80000000000 is not memory, it is just a invalid address, so it cause
crash. 
You mean the user should assure the physical address is valid, right?

Thanks,
Xishi Qiu

>> ...
>> [ 169.147578] ? panic+0x1f1/0x239
>> [ 169.150789] oops_end+0xb8/0xd0
>> [ 169.153910] pgtable_bad+0x8a/0x95
>> [ 169.157294] __do_page_fault+0x3aa/0x4a0
>> [ 169.161194] do_page_fault+0x30/0x80
>> [ 169.164750] ? do_syscall_64+0x175/0x180
>> [ 169.168649] page_fault+0x28/0x30
>>
>> Thanks,
>> Xishi Qiu
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
