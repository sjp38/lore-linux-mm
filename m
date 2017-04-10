Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 996F86B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:06:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f13so13586521wrf.3
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:06:48 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id q71si21426071wrb.291.2017.04.10.07.06.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 07:06:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id C35F898D42
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:06:46 +0000 (UTC)
Date: Mon, 10 Apr 2017 15:06:46 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: NULL pointer dereference in the kernel 3.10
Message-ID: <20170410140646.hyfbzc5367442hty@techsingularity.net>
References: <58E8E81E.6090304@huawei.com>
 <20170410085604.zpenj6ggc3dsbgxw@techsingularity.net>
 <58EB761E.9040002@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58EB761E.9040002@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 10, 2017 at 08:10:06PM +0800, zhong jiang wrote:
> On 2017/4/10 16:56, Mel Gorman wrote:
> > On Sat, Apr 08, 2017 at 09:39:42PM +0800, zhong jiang wrote:
> >> when runing the stabile docker cases in the vm.   The following issue will come up.
> >>
> >> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
> >>     [exception RIP: down_read_trylock+5]
> >>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
> >>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
> >>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
> >>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
> >>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
> >>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
> >>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
> > Post the full report including the kernel version and state whether any
> > additional patches to 3.10 are applied.
> >
>  Hi, Mel
>    
>         Our kernel from RHEL 7.2, Addtional patches all from upstream -- include Bugfix and CVE.
> 
> Commit 624483f3ea8 ("mm: rmap: fix use-after-free in __put_anon_vma") exclude in
> the RHEL 7.2. it looks seems to the issue. but I don't know how it triggered.
> or it is not the correct fix.  Any suggestion? Thanks
> 

I'm afraid you'll need to bring it up with RHEL support as it contains
a number of backported patches from them that cannot be meaningfully
evaluated outside of RedHat and they may have additional questions on the
patches applied on top.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
