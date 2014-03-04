Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 98C296B003A
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 17:47:00 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id 142so568592ykq.0
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 14:47:00 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t49si669892yhd.9.2014.03.04.14.46.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 14:47:00 -0800 (PST)
Message-ID: <531657DC.4050204@oracle.com>
Date: Tue, 04 Mar 2014 17:46:52 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
References: <53126861.7040107@oracle.com> <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5314E0CD.6070308@oracle.com> <5314F661.30202@oracle.com> <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On 03/04/2014 04:32 PM, Naoya Horiguchi wrote:
> # sorry if duplicate message
> 
> On Mon, Mar 03, 2014 at 04:38:41PM -0500, Sasha Levin wrote:
>> On 03/03/2014 03:06 PM, Sasha Levin wrote:
>>> On 03/03/2014 12:02 AM, Naoya Horiguchi wrote:
>>>> Hi Sasha,
>>>>
>>>>>> I can confirm that with this patch the lockdep issue is gone. However, the NULL deref in
>>>>>> walk_pte_range() and the BUG at mm/hugemem.c:3580 still appear.
>>>> I spotted the cause of this problem.
>>>> Could you try testing if this patch fixes it?
>>>
>>> I'm seeing a different failure with this patch:
>>
>> And the NULL deref still happens.
> 
> I don't yet find out the root reason why this issue remains.
> So I tried to run trinity myself but the problem didn't reproduce.
> (I did simply like "./trinity --group vm --dangerous" a few hours.)
> Could you show more detail or tips about how the problem occurs?

I run it as root in a disposable vm, that may be the difference here.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
