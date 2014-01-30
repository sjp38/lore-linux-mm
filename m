Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 33F9F6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:26:29 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id at1so3625616iec.25
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 12:26:28 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id jc1si36922112igb.69.2014.01.30.12.26.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 12:26:25 -0800 (PST)
Message-ID: <52EAB56E.2030102@infradead.org>
Date: Thu, 30 Jan 2014 12:26:22 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [BUG] Description for memmap in kernel-parameters.txt is wrong
References: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com>	<52EAA714.3080809@infradead.org> <CAOvWMLbs-sP+gJHV_5O6ZbV8eTpEKPVRVR238gFcPQeqhCjT3A@mail.gmail.com>
In-Reply-To: <CAOvWMLbs-sP+gJHV_5O6ZbV8eTpEKPVRVR238gFcPQeqhCjT3A@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andiry Xu <andiry@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andiry Xu <andiry.xu@gmail.com>, Linux MM <linux-mm@kvack.org>

On 01/30/2014 11:33 AM, Andiry Xu wrote:
> On Thu, Jan 30, 2014 at 11:25 AM, Randy Dunlap <rdunlap@infradead.org> wrote:
>> [adding linux-mm mailing list]
>>
>> On 01/30/2014 08:52 AM, Andiry Xu wrote:
>>> Hi,
>>>
>>> In kernel-parameters.txt, there is following description:
>>>
>>> memmap=nn[KMG]$ss[KMG]
>>>                         [KNL,ACPI] Mark specific memory as reserved.
>>>                         Region of memory to be used, from ss to ss+nn.
>>
>> Should be:
>>                           Region of memory to be reserved, from ss to ss+nn.
>>
>> but that doesn't help with the problem that you describe, does it?
>>
> 
> Actually it should be:
>                              Region of memory to be reserved, from nn to nn+ss.
> 
> That is, exchange nn and ss.

Yes, I understand that that's what you are reporting.  I just haven't yet
worked out how the code manages to exchange those 2 values.

>>
>>> Unfortunately this is incorrect. The meaning of nn and ss is reversed.
>>> For example:
>>>
>>> Command                  Expected                 Result
>>> memmap 2G$6G        6G - 8G reserved      2G - 8G reserved
>>> memmap 6G$2G        2G - 8G reserved      6G - 8G reserved
>>
>> Are you testing on x86?
>> The code in arch/x86/kernel/e820.c always parses mem_size followed by start address.
>> I don't (yet) see where it goes wrong...
>>
> 
> Yes, it's a x86 machine.
> 
>>
>>> Test kernel version 3.13, but I believe the issue has been there long ago.
>>>
>>> I'm not sure whether the description or implementation should be
>>> fixed, but apparently they do not match.
>>
>> I prefer to change the documentation and leave the implementation as is.
>>
> 
> That's fine. memmap itself works OK, it's just the description is
> wrong and people like me get confused.
> 
> Thanks,
> Andiry


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
