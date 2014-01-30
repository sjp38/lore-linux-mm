Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f53.google.com (mail-vb0-f53.google.com [209.85.212.53])
	by kanga.kvack.org (Postfix) with ESMTP id 27A876B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 18:43:51 -0500 (EST)
Received: by mail-vb0-f53.google.com with SMTP id p17so2442105vbe.40
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:43:50 -0800 (PST)
Received: from mail-ve0-x234.google.com (mail-ve0-x234.google.com [2607:f8b0:400c:c01::234])
        by mx.google.com with ESMTPS id ke3si2685758veb.141.2014.01.30.15.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 15:43:50 -0800 (PST)
Received: by mail-ve0-f180.google.com with SMTP id db12so2617415veb.39
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:43:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52EAD810.40204@infradead.org>
References: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com>
	<52EAA714.3080809@infradead.org>
	<CAOvWMLbs-sP+gJHV_5O6ZbV8eTpEKPVRVR238gFcPQeqhCjT3A@mail.gmail.com>
	<52EAB56E.2030102@infradead.org>
	<alpine.DEB.2.02.1401301416030.15271@chino.kir.corp.google.com>
	<52EAD810.40204@infradead.org>
Date: Thu, 30 Jan 2014 15:43:50 -0800
Message-ID: <CAOmQrk1aghJrFb6RNO1yTwN51Brk_88O9k8OuCm_QshP3zag-Q@mail.gmail.com>
Subject: Re: [BUG] Description for memmap in kernel-parameters.txt is wrong
From: Andiry Xu <andiry.xu@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Andiry Xu <andiry@gmail.com>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Thu, Jan 30, 2014 at 2:54 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 01/30/2014 02:17 PM, David Rientjes wrote:
>> On Thu, 30 Jan 2014, Randy Dunlap wrote:
>>
>>>>>> Hi,
>>>>>>
>>>>>> In kernel-parameters.txt, there is following description:
>>>>>>
>>>>>> memmap=nn[KMG]$ss[KMG]
>>>>>>                         [KNL,ACPI] Mark specific memory as reserved.
>>>>>>                         Region of memory to be used, from ss to ss+nn.
>>>>>
>>>>> Should be:
>>>>>                           Region of memory to be reserved, from ss to ss+nn.
>>>>>
>>>>> but that doesn't help with the problem that you describe, does it?
>>>>>
>>>>
>>>> Actually it should be:
>>>>                              Region of memory to be reserved, from nn to nn+ss.
>>>>
>>>> That is, exchange nn and ss.
>>>
>>> Yes, I understand that that's what you are reporting.  I just haven't yet
>>> worked out how the code manages to exchange those 2 values.
>>>
>>
>> It doesn't, the documentation is correct as written and could be improved
>> by your suggestion of "Region of memory to be reserved, from ss to ss+nn."
>> I think Andiry probably is having a problem with his bootloader
>> interpreting the '$' incorrectly (or variable expansion if coming from the
>> shell) or interpreting the resulting user-defined e820 map incorrectly.
>> --
>
> Yeah, I certainly don't see a problem with the code and I would want to
> see/understand that before I exchanged the 2 values in the documentation.
>
> I'll submit a patch to make the wording a bit better.
>

I'm using Ubuntu 13.04 with GRUB2. If it's a bootloader issue, what should I do?

Thanks,
Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
