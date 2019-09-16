Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 947AFC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 636F8206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:27:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 636F8206A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 154276B0005; Mon, 16 Sep 2019 11:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105DA6B0006; Mon, 16 Sep 2019 11:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F37746B0007; Mon, 16 Sep 2019 11:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id D05C36B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:27:58 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6B26E824CA38
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:27:58 +0000 (UTC)
X-FDA: 75941164236.07.group33_629121ee5dd1b
X-HE-Tag: group33_629121ee5dd1b
X-Filterd-Recvd-Size: 3559
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:27:57 +0000 (UTC)
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 75CD1E9BD1341E81870C;
	Mon, 16 Sep 2019 23:27:46 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Mon, 16 Sep 2019
 23:27:38 +0800
Message-ID: <5D7FA9E9.4050501@huawei.com>
Date: Mon, 16 Sep 2019 23:27:37 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Laurent Dufour <ldufour@linux.ibm.com>
CC: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>, <charante@codeaurora.org>
Subject: Re: Speculative page faults
References: <5D74BC65.4070309@huawei.com> <b681a5c4-5bb8-4e6c-3323-30e1645782c3@linux.ibm.com>
In-Reply-To: <b681a5c4-5bb8-4e6c-3323-30e1645782c3@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/9/13 19:12, Laurent Dufour wrote:
> Le 08/09/2019 =C3=A0 10:31, zhong jiang a =C3=A9crit :
>> Hi, Laurent,  Vinayak
>>
>> I have got the following crash on 4.14 kernel with speculative page fa=
ults enabled.
>> Unfortunately,  The issue disappears when trying disabling SPF.
>
> Hi Zhong,
>
> Sorry for to late answer, I was busy at the LPC.
>
> I never hit that.
>
> Is there any steps identified leading to this crash ?
>
It's strange to me for this situation.

The issue doesn't come up recently. I just run testcases in user space.
And I do noting. I do know why it disappears.

It is alway NULL pointer when the panic comes up. I doesn't see any suspi=
cion
from the code. And I try to construct some cases about race between spf p=
ath and
thread exit. but It fails to recur the issue.

Thanks,
zhong jiang
> Thanks,
> Laurent.
>
>
>> The call trace is as follows.
>>
>> Unable to handle kernel NULL pointer dereference at virtual address 00=
000000
>> user pgtable: 4k pages, 39-bit VAs, pgd =3D ffffffc177337000
>> [0000000000000000] *pgd=3D0000000177346003, *pud=3D0000000177346003, *=
pmd=3D0000000000000000
>> Internal error: Oops: 96000046 [#1] PREEMPT SMP
>>
>> CPU: 0 PID: 3184 Comm: Signal Catcher VIP: 00 Tainted: G           O  =
  4.14.116 #1
>> PC is at __rb_erase_color+0x54/0x260
>> LR is at anon_vma_interval_tree_remove+0x2ac/0x2c0
>>
>> Call trace:
>> [<ffffff8009aa45c4>] __rb_erase_color+0x54/0x260
>> [<ffffff80083a73f8>] anon_vma_interval_tree_remove+0x2ac/0x2c0
>> [<ffffff80083b96ac>] unlink_anon_vmas+0x84/0x170
>> [<ffffff80083aa8f4>] free_pgtables+0x9c/0x100
>> [<ffffff80083b6814>] exit_mmap+0xb0/0x1d8
>> [<ffffff8008227e8c>] mmput+0x3c/0xe0
>> [ffffff800822ed00>] do_exit+0x2f0/0x954
>> [<ffffff800822f41c>] do_group_exit+0x88/0x9c
>> [<ffffff800823b768>] get_signal+0x360/0x56c
>> [<ffffff8008208eb8>] do_notify_resume+0x150/0x5e4
>> Exception stack(0xffffffc1eac07ec0 to 0xffffffc1eac08000)
>>
>> It seems to rb_node is empty accidentally under anon_vma rwsem when th=
e process is exiting.
>> I have no idea whether any race existence or not to result in the issu=
e.
>>
>> Let me know if you have hit the issue or any  suggestions.
>>
>> Thanks,
>> zhong jiang
>>
>
>
>
> .
>



