Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D85CD6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:15:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q87so154033469pfk.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:15:50 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b8si8784829plk.35.2017.07.25.04.15.48
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 04:15:49 -0700 (PDT)
Subject: Re: [PATCH v2] mm: Drop useless local parameters of
 __register_one_node()
References: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <87d18o7uie.fsf@concordia.ellerman.id.au>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <96d20c3c-8f4f-416e-edb7-7bc36fc3827b@cn.fujitsu.com>
Date: Tue, 25 Jul 2017 19:15:42 +0800
MIME-Version: 1.0
In-Reply-To: <87d18o7uie.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset="gbk"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, isimatu.yasuaki@jp.fujitsu.com

Hi Michael,

At 07/25/2017 05:09 PM, Michael Ellerman wrote:
> Dou Liyang <douly.fnst@cn.fujitsu.com> writes:
>
>> ... initializes local parameters "p_node" & "parent" for
>> register_node().
>>
>> But, register_node() does not use them.
>>
>> Remove the related code of "parent" node, cleanup __register_one_node()
>> and register_node().
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: isimatu.yasuaki@jp.fujitsu.com
>> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>> ---
>> V1 --> V2:
>> Rebase it on
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
>>
>>  drivers/base/node.c | 9 ++-------
>>  1 file changed, 2 insertions(+), 7 deletions(-)
>
> That appears to be the last user of parent_node().

Oops, yes, it is the last one.

>
> Can we start removing it from the topology.h headers for each arch?
>

Yes, I think so.

Thanks,
	dou.

> cheers
>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
