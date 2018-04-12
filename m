Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C53736B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:37:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f137so24383wme.5
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:37:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor3478200edb.46.2018.04.12.11.37.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 11:37:49 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
References: <20180412153941.170849-1-jannh@google.com> <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 12 Apr 2018 20:37:29 +0200
Message-ID: <CAKgNAkgcJ2kCTff0=7=D3zPFwpJt-9EM8yis6-4qDjfvvb8ukw@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jann Horn <jannh@google.com>, linux-man <linux-man@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi John,

On 12 April 2018 at 20:33, John Hubbard <jhubbard@nvidia.com> wrote:
> On 04/12/2018 08:39 AM, Jann Horn wrote:
>> Clarify that MAP_FIXED is appropriate if the specified address range has
>> been reserved using an existing mapping, but shouldn't be used otherwise.
>>
>> Signed-off-by: Jann Horn <jannh@google.com>
>> ---
>>  man2/mmap.2 | 19 +++++++++++--------
>>  1 file changed, 11 insertions(+), 8 deletions(-)
>>
>> diff --git a/man2/mmap.2 b/man2/mmap.2
>> index bef8b4432..80c9ec285 100644
>> --- a/man2/mmap.2
>> +++ b/man2/mmap.2
>> @@ -253,8 +253,9 @@ Software that aspires to be portable should use this option with care,
>>  keeping in mind that the exact layout of a process's memory mappings
>>  is allowed to change significantly between kernel versions,
>>  C library versions, and operating system releases.
>> -Furthermore, this option is extremely hazardous (when used on its own),
>> -because it forcibly removes preexisting mappings,
>> +This option should only be used when the specified memory region has
>> +already been reserved using another mapping; otherwise, it is extremely
>> +hazardous because it forcibly removes preexisting mappings,
>>  making it easy for a multithreaded process to corrupt its own address space.
>
> Yes, that's clearer and provides more information than before.
>
>>  .IP
>>  For example, suppose that thread A looks through
>> @@ -284,13 +285,15 @@ and the PAM libraries
>>  .UR http://www.linux-pam.org
>>  .UE .
>>  .IP
>> -Newer kernels
>> -(Linux 4.17 and later) have a
>> +For cases in which the specified memory region has not been reserved using an
>> +existing mapping, newer kernels (Linux 4.17 and later) provide an option
>>  .B MAP_FIXED_NOREPLACE
>> -option that avoids the corruption problem; if available,
>> -.B MAP_FIXED_NOREPLACE
>> -should be preferred over
>> -.BR MAP_FIXED .
>> +that should be used instead; older kernels require the caller to use
>> +.I addr
>> +as a hint (without
>> +.BR MAP_FIXED )
>
> Here, I got lost: the sentence suddenly jumps into explaining non-MAP_FIXED
> behavior, in the MAP_FIXED section. Maybe if you break up the sentence, and
> possibly omit non-MAP_FIXED discussion, it will help.

Hmmm -- true. That piece could be a little clearer.

Jann, I've already pushed the existing patch. Do you want to add a patch on top?

Thanks,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
