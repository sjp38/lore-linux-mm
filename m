Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC5396B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 22:16:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10so1866221itg.3
        for <linux-mm@kvack.org>; Thu, 25 May 2017 19:16:06 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id x8si12237412itx.32.2017.05.25.19.16.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 19:16:06 -0700 (PDT)
Message-ID: <59278B13.4070304@huawei.com>
Date: Fri, 26 May 2017 09:55:31 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in __insert_vmap_area()
References: <20170524100347.8131-1-richard.weiyang@gmail.com> <592649CC.8090702@huawei.com> <20170526013639.GA10727@WeideMacBook-Pro.local>
In-Reply-To: <20170526013639.GA10727@WeideMacBook-Pro.local>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/5/26 9:36, Wei Yang wrote:
> On Thu, May 25, 2017 at 11:04:44AM +0800, zhong jiang wrote:
>> I hit the overlap issue, but it  is hard to reproduced. if you think it is safe. and the situation
>> is not happen. AFAIC, it is no need to add the code.
>>
>> if you insist on the point. Maybe VM_WARN_ON is a choice.
>>
> Do you have some log to show the overlap happens?
 Hi  wei

cat /proc/vmallocinfo
0xf1580000-0xf1600000  524288 raw_dump_mem_write+0x10c/0x188 phys=8b901000 ioremap
0xf1638000-0xf163a000    8192 mcss_pou_queue_init+0xa0/0x13c [mcss] phys=fc614000 ioremap
0xf528e000-0xf5292000   16384 n_tty_open+0x10/0xd0 pages=3 vmalloc
0xf5000000-0xf9001000 67112960 devm_ioremap+0x38/0x70 phys=40000000 ioremap
0xfe001000-0xfe002000    4096 iotable_init+0x0/0xc phys=20001000 ioremap
0xfe200000-0xfe201000    4096 iotable_init+0x0/0xc phys=1a000000 ioremap
0xff100000-0xff101000    4096 iotable_init+0x0/0xc phys=2000a000 ioremap

I hit the above issue, but the log no more useful info. it just is found by accident.
and it is hard to reprodeced. no more info can be supported for further investigation.
therefore, it is no idea for me. 

Thanks
zhongjinag


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
