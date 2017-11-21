Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3327F6B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:45:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r23so3949726pfg.17
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:45:32 -0800 (PST)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id f5si11151071pgn.126.2017.11.21.07.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 07:45:30 -0800 (PST)
Message-ID: <5A144A17.8010909@windriver.com>
Date: Tue, 21 Nov 2017 09:45:27 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: "swap_free: Bad swap file entry" and "BUG: Bad page map in process"
 but no swap configured
References: <57F6BB8F.7070208@windriver.com> <018601d2213a$bb0e44e0$312acea0$@alibaba-inc.com> <57FD0CF8.2030208@windriver.com> <CAAuJbeJPw9AeuDrO=q8Y+VkUoq1XQLWcbEYVQXywiP5nR=qaVg@mail.gmail.com>
In-Reply-To: <CAAuJbeJPw9AeuDrO=q8Y+VkUoq1XQLWcbEYVQXywiP5nR=qaVg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaitong Han <oenhan@gmail.com>, lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

I think we tracked it down to the "eptad" kernel option on Broadwell processors. 
  Setting "kvm-intel.eptad=0" turned it off.

Chris

On 11/20/2017 03:07 AM, Huaitong Han wrote:
> Hi, Chris
>
> I have met the same issue too, did you have found out the root cause ?
>
> Thanks a lot.
>
> Huaitong Han
>
>
> 2016-10-12 0:02 GMT+08:00 Chris Friesen <chris.friesen@windriver.com>:
>> On 10/08/2016 02:05 AM, Hillf Danton wrote:
>>>
>>> On Friday, October 07, 2016 5:01 AM Chris Friesen
>>>>
>>>>
>>>> I have Linux host running as a kvm hypervisor.  It's running CentOS.  (So
>>>> the
>>>> kernel is based on 3.10 but with loads of stuff backported by RedHat.)  I
>>>> realize this is not a mainline kernel, but I was wondering if anyone is
>>>> aware of
>>>> similar issues that had been fixed in mainline.
>>>>
>>> Hey, dunno if you're looking for commit
>>>          6dec97dc929 ("mm: move_ptes -- Set soft dirty bit depending on pte
>>> type")
>>> Hillf
>>
>>
>> CONFIG_MEM_SOFT_DIRTY doesn't exist in our kernel so I don't think this is
>> the issue.  Thanks for the suggestion though.
>>
>> Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
