Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4616B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 04:43:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z88so13022888wrc.9
        for <linux-mm@kvack.org>; Tue, 02 May 2017 01:43:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a195si1858865wmd.35.2017.05.02.01.43.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 01:43:25 -0700 (PDT)
Date: Tue, 2 May 2017 10:43:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] dev/mem: "memtester -p 0x6c80000000000 10G" cause crash
Message-ID: <20170502084323.GG14593@dhcp22.suse.cz>
References: <59083C5B.5080204@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59083C5B.5080204@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On Tue 02-05-17 15:59:23, Xishi Qiu wrote:
> Hi, I use "memtester -p 0x6c80000000000 10G" to test physical address 0x6c80000000000
> Because this physical address is invalid, and valid_mmap_phys_addr_range()
> always return 1, so it causes crash.
> 
> My question is that should the user assure the physical address is valid?

We already seem to be checking range_is_allowed(). What is your
CONFIG_STRICT_DEVMEM setting? The code seems to be rather confusing but
my assumption is that you better know what you are doing when mapping
this file.

> ...
> [ 169.147578] ? panic+0x1f1/0x239
> [ 169.150789] oops_end+0xb8/0xd0
> [ 169.153910] pgtable_bad+0x8a/0x95
> [ 169.157294] __do_page_fault+0x3aa/0x4a0
> [ 169.161194] do_page_fault+0x30/0x80
> [ 169.164750] ? do_syscall_64+0x175/0x180
> [ 169.168649] page_fault+0x28/0x30
> 
> Thanks,
> Xishi Qiu

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
