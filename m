Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35BAD6B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 04:10:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 38so1631720wrv.8
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 01:10:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor993665wmz.19.2018.04.12.01.10.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 01:10:19 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
References: <20180411120452.1736-1-mhocko@kernel.org>
 <CAG48ez3BS5EtnrhFQUGYY9MKGOUHzFbhauJQd361uTwy2pBEeg@mail.gmail.com>
 <20180411163631.GL23400@dhcp22.suse.cz>
 <CAG48ez2wYqxJEHgZCz5g6ZYBY4_qDcYWSGAErC8pUzmrW62rug@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <6c2df5a8-b33a-915f-f220-da9a6ad08049@gmail.com>
Date: Thu, 12 Apr 2018 10:10:18 +0200
MIME-Version: 1.0
In-Reply-To: <CAG48ez2wYqxJEHgZCz5g6ZYBY4_qDcYWSGAErC8pUzmrW62rug@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: mtk.manpages@gmail.com, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi Jann,

On 04/11/2018 06:40 PM, Jann Horn wrote:
> On Wed, Apr 11, 2018 at 6:36 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Wed 11-04-18 17:37:46, Jann Horn wrote:
>>> On Wed, Apr 11, 2018 at 2:04 PM,  <mhocko@kernel.org> wrote:
>>>> From: Michal Hocko <mhocko@suse.com>
>>>>
>>>> 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
>>>> atomicaly probe for a given address range.
>>>>
>>>> [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
>>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>>> ---
>>>> Hi,
>>>> Andrew's sent the MAP_FIXED_NOREPLACE to Linus for the upcoming merge
>>>> window. So here we go with the man page update.
>>>>
>>>>  man2/mmap.2 | 27 +++++++++++++++++++++++++++
>>>>  1 file changed, 27 insertions(+)
>>>>
>>>> diff --git a/man2/mmap.2 b/man2/mmap.2
>>>> index ea64eb8f0dcc..f702f3e4eba2 100644
>>>> --- a/man2/mmap.2
>>>> +++ b/man2/mmap.2
>>>> @@ -261,6 +261,27 @@ Examples include
>>>>  and the PAM libraries
>>>>  .UR http://www.linux-pam.org
>>>>  .UE .
>>>> +Newer kernels
>>>> +(Linux 4.17 and later) have a
>>>> +.B MAP_FIXED_NOREPLACE
>>>> +option that avoids the corruption problem; if available, MAP_FIXED_NOREPLACE
>>>> +should be preferred over MAP_FIXED.
>>>
>>> This still looks wrong to me. There are legitimate uses for MAP_FIXED,
>>> and for most users of MAP_FIXED that I'm aware of, MAP_FIXED_NOREPLACE
>>> wouldn't work while MAP_FIXED works perfectly well.
>>>
>>> MAP_FIXED is for when you have already reserved the targeted memory
>>> area using another VMA; MAP_FIXED_NOREPLACE is for when you haven't.
>>> Please don't make it sound as if MAP_FIXED is always wrong.
>>
>> Well, this was suggested by John. I think, nobody is objecting that
>> MAP_FIXED has legitimate usecases. The above text just follows up on
>> the previous section which emphasises the potential memory corruption
>> problems and it suggests that a new flag is safe with that regards.
>>
>> If you have specific wording that would be better I am open for changes.
> 
> I guess I'd probably also want to change the previous text; so I
> should probably send a followup patch once this one has landed.
Okay -- I'm ready to take that piece now. Please send me a patch!

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
