Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09EC16B03A0
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:56:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k199so21900818lfg.16
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 01:56:07 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id y86si2188579lfg.28.2017.04.10.01.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 01:56:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id A031F1C1FFB
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:56:05 +0100 (IST)
Date: Mon, 10 Apr 2017 09:56:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: NULL pointer dereference in the kernel 3.10
Message-ID: <20170410085604.zpenj6ggc3dsbgxw@techsingularity.net>
References: <58E8E81E.6090304@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58E8E81E.6090304@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Apr 08, 2017 at 09:39:42PM +0800, zhong jiang wrote:
> when runing the stabile docker cases in the vm.   The following issue will come up.
> 
> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
>     [exception RIP: down_read_trylock+5]
>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000

Post the full report including the kernel version and state whether any
additional patches to 3.10 are applied.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
