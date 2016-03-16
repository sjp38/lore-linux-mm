Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id D58CB6B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 05:49:02 -0400 (EDT)
Received: by mail-lf0-f43.google.com with SMTP id l83so14982932lfd.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 02:49:02 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l16si1201024lfl.202.2016.03.16.02.48.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 02:49:01 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com> <56DE30CB.7020207@huawei.com>
 <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56E92AFC.9050208@huawei.com>
Date: Wed, 16 Mar 2016 17:44:28 +0800
MIME-Version: 1.0
In-Reply-To: <20160314071803.GA28094@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/14 15:18, Joonsoo Kim wrote:
> On Mon, Mar 14, 2016 at 08:06:16AM +0100, Vlastimil Babka wrote:
>> On 03/14/2016 07:49 AM, Joonsoo Kim wrote:
>>> On Fri, Mar 11, 2016 at 06:07:40PM +0100, Vlastimil Babka wrote:
>>>> On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
>>>>
>>>> How about something like this? Just and idea, probably buggy (off-by-one etc.).
>>>> Should keep away cost from <pageblock_order iterations at the expense of the
>>>> relatively fewer >pageblock_order iterations.
>>> Hmm... I tested this and found that it's code size is a little bit
>>> larger than mine. I'm not sure why this happens exactly but I guess it would be
>>> related to compiler optimization. In this case, I'm in favor of my
>>> implementation because it looks like well abstraction. It adds one
>>> unlikely branch to the merge loop but compiler would optimize it to
>>> check it once.
>> I would be surprised if compiler optimized that to check it once, as
>> order increases with each loop iteration. But maybe it's smart
>> enough to do something like I did by hand? Guess I'll check the
>> disassembly.
> Okay. I used following slightly optimized version and I need to
> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
> to yours. Please consider it, too.

Hmm, this one is not work, I still can see the bug is there after applying
this patch, did I miss something?

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
