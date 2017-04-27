Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74E906B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:07:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m26so3217720wrm.5
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:07:25 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j39si2728755wre.322.2017.04.27.07.07.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 07:07:23 -0700 (PDT)
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <20170427134158.GI4706@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f741d053-4303-5441-21bc-ec86bca1164c@huawei.com>
Date: Thu, 27 Apr 2017 17:06:05 +0300
MIME-Version: 1.0
In-Reply-To: <20170427134158.GI4706@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 27/04/17 16:41, Michal Hocko wrote:
> On Wed 26-04-17 18:29:08, Igor Stoppa wrote:
> [...]
>> If you prefer to have this patch only as part of the larger patchset,
>> I'm also fine with it.
> 
> I agree that the situation is not ideal. If a larger set of changes
> would benefit from this change then it would clearly add arguments...

Ok, then I'll send it out as part of the larger RFC set.


>> Also, if you could reply to [1], that would be greatly appreciated.
> 
> I will try to get to it but from a quick glance, yet-another-zone will
> hit a lot of opposition...

The most basic questions, that I hope can be answered with Yes/No =) are:

- should a new zone be added after DMA32?

- should I try hard to keep the mask fitting a 32bit word - at least for
hose who do not use the new zone - or is it ok to just stretch it to 64
bits?



If you could answer these, then I'll have a better idea of what I need
to do to.

TIA, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
