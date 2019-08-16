Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7FB5C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 10:38:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A598206C2
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 10:38:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A598206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF1A36B0003; Fri, 16 Aug 2019 06:38:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA1586B0005; Fri, 16 Aug 2019 06:38:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C91746B0006; Fri, 16 Aug 2019 06:38:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id A71466B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:38:32 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 23AE97817
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:38:32 +0000 (UTC)
X-FDA: 75827942064.05.spark97_84746ced7915f
X-HE-Tag: spark97_84746ced7915f
X-Filterd-Recvd-Size: 4568
Received: from huawei.com (szxga04-in.huawei.com [45.249.212.190])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:38:30 +0000 (UTC)
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 708398D16C9DF4BD3C8A;
	Fri, 16 Aug 2019 18:37:58 +0800 (CST)
Received: from [127.0.0.1] (10.133.217.137) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.439.0; Fri, 16 Aug 2019
 18:37:53 +0800
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
To: Oleg Nesterov <oleg@redhat.com>
CC: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, "Andrea
 Arcangeli" <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Mike Rapoport
	<rppt@linux.ibm.com>, Jann Horn <jannh@google.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com> <20190814154101.GF11595@redhat.com>
 <0cfded81-6668-905f-f2be-490bf7c750fb@huawei.com>
 <20190815095409.GC32051@redhat.com>
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Message-ID: <3b521a8c-586f-251e-f486-d71ff094b8e9@huawei.com>
Date: Fri, 16 Aug 2019 18:37:52 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190815095409.GC32051@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.217.137]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/8/15 17:54, Oleg Nesterov wrote:
> On 08/15, Kefeng Wang wrote:
>>
>> On 2019/8/14 23:41, Oleg Nesterov wrote:
>>>
>>> Heh, I didn't notice you too mentioned userfaultfd_release() in your email.
>>> can you try the patch below?
>>
>> Your patch below fixes the issue, could you send a formal patch ASAP and also it
>> should be queued into stable, I have test lts4.4, it works too, thanks.
> 
> Thanks.
> 
> Yes, I _think_ we need something like this patch anyway, but it needs more
> discussion. And it is not clear if it really fixes this issue or it hides
> another bug.
> 

OK, hope more specialists notice this issue and comment it.

> 
>> I built kernel with wrong gcc version, and the KASAN is not enabled, When KASAN enabled,
>> there is an UAF,
>>
>> [   67.393442] ==================================================================
>> [   67.395531] BUG: KASAN: use-after-free in handle_userfault+0x12f/0xc70
>> [   67.397001] Read of size 8 at addr ffff8883c622c160 by task syz-executor.9/5225
> 
> OK, thanks this probably confirms that .ctx points to nowhere because it
> was freed by userfaultfd_release() without clearing vm_flags/userfaultfd_ctx.

The patch do fix the UAF and avoid panic, and it doesn't seem to cause new issue,
even if there are some another issue, it can be fixed later :)

> 
> But,
> 
>> [   67.430243] RIP: 0010:copy_user_handle_tail+0x2/0x10
>> [   67.431586] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
>> [   67.436978] RSP: 0018:ffff8883c4e8f908 EFLAGS: 00010246
>> [   67.438743] RAX: 0000000000000001 RBX: 0000000020ffd000 RCX: 0000000000001000
>> [   67.441101] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8883c0aa4000
>> [   67.442865] RBP: 0000000000001000 R08: ffffed1078154a00 R09: 0000000000000000
>> [   67.444534] R10: 0000000000000200 R11: ffffed10781549ff R12: ffff8883c0aa4000
>> [   67.446216] R13: ffff8883c6096000 R14: ffff88837721f838 R15: ffff8883c6096000
>> [   67.448388]  _copy_from_user+0xa1/0xd0
>> [   67.449655]  mcopy_atomic+0xb3d/0x1380
>> [   67.450991]  ? lock_downgrade+0x3a0/0x3a0
>> [   67.452337]  ? mm_alloc_pmd+0x130/0x130
>> [   67.453618]  ? __might_fault+0x7d/0xe0
>> [   67.454980]  userfaultfd_ioctl+0x14a2/0x1c30
> 
> This must not be called after __fput(). So I think there is something else,
> may by just an unbalanced userfaultfd_ctx_put(). I dunno, I know nothing
> about usefaultfd.

There are different processes, maybe some concurrency problems.

> 
> It would be nice to understand what this reproducer does...

I tried strace -f the reproducer, but can't find any useful info.

> 
> Oleg.
> 
> 
> .
> 


