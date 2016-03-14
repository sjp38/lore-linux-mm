Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0EA6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:17:02 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so91972802pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:17:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v11si1930803par.167.2016.03.14.00.17.00
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 00:17:01 -0700 (PDT)
Date: Mon, 14 Mar 2016 16:18:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160314071803.GA28094@js1304-P5Q-DELUXE>
References: <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE>
 <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com>
 <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz>
 <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E662E8.700@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
> >On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
> >>On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
> >>
> >>How about something like this? Just and idea, probably buggy (off-by-one etc.).
> >>Should keep away cost from <pageblock_order iterations at the expense of the
> >>relatively fewer >pageblock_order iterations.
> >
> >Hmm... I tested this and found that it's code size is a little bit
> >larger than mine. I'm not sure why this happens exactly but I guess it would be
> >related to compiler optimization. In this case, I'm in favor of my
> >implementation because it looks like well abstraction. It adds one
> >unlikely branch to the merge loop but compiler would optimize it to
> >check it once.
> 
> I would be surprised if compiler optimized that to check it once, as
> order increases with each loop iteration. But maybe it's smart
> enough to do something like I did by hand? Guess I'll check the
> disassembly.

Okay. I used following slightly optimized version and I need to
add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
to yours. Please consider it, too.

Thanks.

------------------------>8------------------------
