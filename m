Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id A412E6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 20:26:23 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id t7so168579740vkf.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 17:26:23 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id y193si377119vke.10.2016.06.02.17.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 17:26:22 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id c189so11052363vkb.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 17:26:22 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152822.FE8D405E@viggo.jf.intel.com>
 <20160601123705.72a606e7@lwn.net> <574F386A.8070106@sr71.net>
 <CAKgNAkiyD_2tAxrBxirxViViMUsfLRRqQp5HowM58dG21LAa7Q@mail.gmail.com>
 <574F7B16.4080906@sr71.net>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <5499ff55-ae0f-e54c-05fd-b1e76dc05a89@gmail.com>
Date: Thu, 2 Jun 2016 19:26:03 -0500
MIME-Version: 1.0
In-Reply-To: <574F7B16.4080906@sr71.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: mtk.manpages@gmail.com, Jonathan Corbet <corbet@lwn.net>, lkml <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 06/01/2016 07:17 PM, Dave Hansen wrote:
> On 06/01/2016 05:11 PM, Michael Kerrisk (man-pages) wrote:
>>>>>>
>>>>>> If I read this right, it doesn't actually remove any pkey restrictions
>>>>>> that may have been applied while the key was allocated.  So there could be
>>>>>> pages with that key assigned that might do surprising things if the key is
>>>>>> reallocated for another use later, right?  Is that how the API is intended
>>>>>> to work?
>>>>
>>>> Yeah, that's how it works.
>>>>
>>>> It's not ideal.  It would be _best_ if we during mm_pkey_free(), we
>>>> ensured that no VMAs under that mm have that vma_pkey() set.  But, that
>>>> search would be potentially expensive (a walk over all VMAs), or would
>>>> force us to keep a data structure with a count of all the VMAs with a
>>>> given key.
>>>>
>>>> I should probably discuss this behavior in the manpages and address it
>> s/probably//
>>
>> And, did I miss it. Was there an updated man-pages patch in the latest
>> series? I did not notice it.
> 
> There have been to changes to the patches that warranted updating the
> manpages until now.  I'll send the update immediately.

Do those updated pages include discussion of the point noted above?
I could not see it mentioned there.

Just by the way, the above behavior seems to offer possibilities
for users to shoot themselves in the foot, in a way that has security
implications. (Or do I misunderstand?)

Thanks,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
