Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 970D96B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:07:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x63so6045472wmf.2
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:07:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z66sor768333wmb.10.2017.11.20.01.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 01:07:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <57FD0CF8.2030208@windriver.com>
References: <57F6BB8F.7070208@windriver.com> <018601d2213a$bb0e44e0$312acea0$@alibaba-inc.com>
 <57FD0CF8.2030208@windriver.com>
From: Huaitong Han <oenhan@gmail.com>
Date: Mon, 20 Nov 2017 17:07:08 +0800
Message-ID: <CAAuJbeJPw9AeuDrO=q8Y+VkUoq1XQLWcbEYVQXywiP5nR=qaVg@mail.gmail.com>
Subject: Re: "swap_free: Bad swap file entry" and "BUG: Bad page map in
 process" but no swap configured
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Chris Friesen <chris.friesen@windriver.com>

Hi, Chris

I have met the same issue too, did you have found out the root cause ?

Thanks a lot.

Huaitong Han


2016-10-12 0:02 GMT+08:00 Chris Friesen <chris.friesen@windriver.com>:
> On 10/08/2016 02:05 AM, Hillf Danton wrote:
>>
>> On Friday, October 07, 2016 5:01 AM Chris Friesen
>>>
>>>
>>> I have Linux host running as a kvm hypervisor.  It's running CentOS.  (So
>>> the
>>> kernel is based on 3.10 but with loads of stuff backported by RedHat.)  I
>>> realize this is not a mainline kernel, but I was wondering if anyone is
>>> aware of
>>> similar issues that had been fixed in mainline.
>>>
>> Hey, dunno if you're looking for commit
>>         6dec97dc929 ("mm: move_ptes -- Set soft dirty bit depending on pte
>> type")
>> Hillf
>
>
> CONFIG_MEM_SOFT_DIRTY doesn't exist in our kernel so I don't think this is
> the issue.  Thanks for the suggestion though.
>
> Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
