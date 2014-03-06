Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5C65B6B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 23:32:05 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id m20so2279954qcx.24
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 20:32:05 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c108si2427712qgf.172.2014.03.05.20.32.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 20:32:05 -0800 (PST)
Message-ID: <5317FA3B.8060900@oracle.com>
Date: Wed, 05 Mar 2014 23:31:55 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
References: <53126861.7040107@oracle.com> <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5314E0CD.6070308@oracle.com> <5314F661.30202@oracle.com> <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com> <531657DC.4050204@oracle.com> <1393976967-lnmm5xcs@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1393976967-lnmm5xcs@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On 03/04/2014 06:49 PM, Naoya Horiguchi wrote:
> On Tue, Mar 04, 2014 at 05:46:52PM -0500, Sasha Levin wrote:
>> On 03/04/2014 04:32 PM, Naoya Horiguchi wrote:
>>> # sorry if duplicate message
>>>
>>> On Mon, Mar 03, 2014 at 04:38:41PM -0500, Sasha Levin wrote:
>>>> On 03/03/2014 03:06 PM, Sasha Levin wrote:
>>>>> On 03/03/2014 12:02 AM, Naoya Horiguchi wrote:
>>>>>> Hi Sasha,
>>>>>>
>>>>>>>> I can confirm that with this patch the lockdep issue is gone. However, the NULL deref in
>>>>>>>> walk_pte_range() and the BUG at mm/hugemem.c:3580 still appear.
>>>>>> I spotted the cause of this problem.
>>>>>> Could you try testing if this patch fixes it?
>>>>>
>>>>> I'm seeing a different failure with this patch:
>>>>
>>>> And the NULL deref still happens.
>>>
>>> I don't yet find out the root reason why this issue remains.
>>> So I tried to run trinity myself but the problem didn't reproduce.
>>> (I did simply like "./trinity --group vm --dangerous" a few hours.)
>>> Could you show more detail or tips about how the problem occurs?
>>
>> I run it as root in a disposable vm, that may be the difference here.
> 
> Sorry, I didn't write it but I also run it as root on VM, so condition is
> the same. It might depend on kernel config, so I'm now trying the config
> you previously gave me, but it doesn't boot correctly on my environment
> (panic in initialization). I may need some time to get over this.

I'd be happy to help with anything off-list, it shouldn't be too difficult
to get that kernel to boot :)

I've also reverted the page walker series for now, it makes it impossible
to test anything else since it seems that hitting one of the issues is quite
easy.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
