Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73D386B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 16:36:25 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v187so1953865qka.5
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 13:36:25 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d21si2475703qkg.289.2018.04.11.13.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 13:36:23 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
References: <20180411120452.1736-1-mhocko@kernel.org>
 <CAG48ez3BS5EtnrhFQUGYY9MKGOUHzFbhauJQd361uTwy2pBEeg@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <827ead33-5d93-7696-9c5e-1cd04f772476@nvidia.com>
Date: Wed, 11 Apr 2018 13:36:21 -0700
MIME-Version: 1.0
In-Reply-To: <CAG48ez3BS5EtnrhFQUGYY9MKGOUHzFbhauJQd361uTwy2pBEeg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/11/2018 08:37 AM, Jann Horn wrote:
> On Wed, Apr 11, 2018 at 2:04 PM,  <mhocko@kernel.org> wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
>> atomicaly probe for a given address range.
>>
>> [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>> Hi,
>> Andrew's sent the MAP_FIXED_NOREPLACE to Linus for the upcoming merge
>> window. So here we go with the man page update.
>>
>>  man2/mmap.2 | 27 +++++++++++++++++++++++++++
>>  1 file changed, 27 insertions(+)
>>
>> diff --git a/man2/mmap.2 b/man2/mmap.2
>> index ea64eb8f0dcc..f702f3e4eba2 100644
>> --- a/man2/mmap.2
>> +++ b/man2/mmap.2
>> @@ -261,6 +261,27 @@ Examples include
>>  and the PAM libraries
>>  .UR http://www.linux-pam.org
>>  .UE .
>> +Newer kernels
>> +(Linux 4.17 and later) have a
>> +.B MAP_FIXED_NOREPLACE
>> +option that avoids the corruption problem; if available, MAP_FIXED_NOREPLACE
>> +should be preferred over MAP_FIXED.
> 
> This still looks wrong to me. There are legitimate uses for MAP_FIXED,
> and for most users of MAP_FIXED that I'm aware of, MAP_FIXED_NOREPLACE
> wouldn't work while MAP_FIXED works perfectly well.
> 
> MAP_FIXED is for when you have already reserved the targeted memory
> area using another VMA; MAP_FIXED_NOREPLACE is for when you haven't.

That's a nice summary, I hope it shows up in your upcoming patch. I recall
that we went back and forth, trying to find a balance of explaining
this feature, without providing overly-elaborate examples (which I tend
toward).

> Please don't make it sound as if MAP_FIXED is always wrong.
> 

Agreed.

thanks,
-- 
John Hubbard
NVIDIA
