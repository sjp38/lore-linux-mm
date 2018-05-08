Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 621C16B02AA
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:25:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z24so17930409pfn.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:25:05 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y23-v6si14982487pgv.318.2018.05.08.09.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:25:04 -0700 (PDT)
Subject: Re: [PATCH] x86/boot/64/clang: Use fixup_pointer() to access
 '__supported_pte_mask'
References: <20180508121638.174022-1-glider@google.com>
 <1f69bdb6-df5e-d709-064a-4f6fdd6e11a7@linux.intel.com>
 <CAG_fn=Xv74c80swzFjKyybQpRj7Qj9K1NVH-D6gcxcYEoUJ1xA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d149aae8-6aba-bb31-ddd6-49244598a617@intel.com>
Date: Tue, 8 May 2018 09:25:01 -0700
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Xv74c80swzFjKyybQpRj7Qj9K1NVH-D6gcxcYEoUJ1xA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Dmitriy Vyukov <dvyukov@google.com>, Michael Davidson <md@google.com>

On 05/08/2018 07:50 AM, Alexander Potapenko wrote:
>>> Similarly to commit 187e91fe5e91
>>> ("x86/boot/64/clang: Use fixup_pointer() to access 'next_early_pgt'"),
>>> '__supported_pte_mask' must be also accessed using fixup_pointer() to
>>> avoid position-dependent relocations.
>>>
>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>> Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")
> 
>> In the interests of standalone changelogs, I'd really appreciate an
>> actual explanation of what's going on here.  Your patch makes the code
>> uglier and doesn't fix anything functional from what I can see.
> You're right, sure. I'll send a patch with an updated description.

Great, thanks!

>> Do we have anything we can do to keep us from recreating these kinds of
>> regressions all the time?
> I'm not really aware of the possible options in the kernel land. Looks like
> a task for some objtool-like utility?
> As long as these regressions are caught with Clang, setting up a 0day Clang
> builder might help.

I've asked the 0day folks if this is doable.  It would be great to see
it added.
