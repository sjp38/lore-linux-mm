Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3227B6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 11:43:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b1so3912121qtc.4
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 08:43:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor6499674qta.58.2017.09.14.08.43.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 08:43:13 -0700 (PDT)
Subject: Re: [PATCH] mm/memory_hotplug: fix wrong casting for
 __remove_section()
References: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
 <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
 <587bdecd-2584-21be-94b8-61b427f1b0e8@gmail.com>
 <20170913055914.3npcxevhdwghcmdd@dhcp22.suse.cz>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <509197e7-135d-1304-76f1-32ae1fcbf223@gmail.com>
Date: Thu, 14 Sep 2017 11:43:10 -0400
MIME-Version: 1.0
In-Reply-To: <20170913055914.3npcxevhdwghcmdd@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>, yasu.isimatu@gmail.com

Hi Michal,

On 09/13/2017 01:59 AM, Michal Hocko wrote:
> On Tue 12-09-17 13:05:39, YASUAKI ISHIMATSU wrote:
>> Hi Michal,
>>
>> Thanks you for reviewing my patch.
>>
>> On 09/12/2017 08:49 AM, Michal Hocko wrote:
>>> On Fri 08-09-17 16:43:04, YASUAKI ISHIMATSU wrote:
>>>> __remove_section() calls __remove_zone() to shrink zone and pgdat.
>>>> But due to wrong castings, __remvoe_zone() cannot shrink zone
>>>> and pgdat correctly if pfn is over 0xffffffff.
>>>>
>>>> So the patch fixes the following 3 wrong castings.
>>>>
>>>>   1. find_smallest_section_pfn() returns 0 or start_pfn which defined
>>>>      as unsigned long. But the function always returns 32bit value
>>>>      since the function is defined as int.
>>>>
>>>>   2. find_biggest_section_pfn() returns 0 or pfn which defined as
>>>>      unsigned long. the function always returns 32bit value
>>>>      since the function is defined as int.
>>>
>>> this is indeed wrong. Pfns over would be really broken 15TB. Not that
>>> unrealistic these days
>>
>> Why 15TB?
> 
> 0xffffffff>>28
> 

Even thought I see your explanation, I cannot understand.

In my understanding, find_{smallest|biggest}_section_pfn() return integer.
So the functions always return 0x00000000 - 0xffffffff. Therefore if pfn is over
0xffffffff (under 16TB), then the function cannot work correctly.

What am I wrong?

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
