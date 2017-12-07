Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9490B6B0069
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:08:27 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 184so2513549oii.1
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:08:27 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 35si1516725otc.402.2017.12.06.17.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 17:08:21 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <87zi6we9z2.fsf@concordia.ellerman.id.au>
 <a3b3129a-2626-a65e-59b0-68aada523723@prevas.dk>
 <20171206090803.GG16386@dhcp22.suse.cz>
 <CAGXu5jKGsAjwF7nE_vjaWPnG0QJRx_qFeiSBLRg_g73iUJ-pwA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c427dc00-2835-a475-1ef5-f5550c4113a0@nvidia.com>
Date: Wed, 6 Dec 2017 17:08:19 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKGsAjwF7nE_vjaWPnG0QJRx_qFeiSBLRg_g73iUJ-pwA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Rasmus Villemoes <rasmus.villemoes@prevas.dk>, Michael Ellerman <mpe@ellerman.id.au>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Matthew Wilcox <willy@infradead.org>

On 12/06/2017 04:19 PM, Kees Cook wrote:
> On Wed, Dec 6, 2017 at 1:08 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Wed 06-12-17 08:33:37, Rasmus Villemoes wrote:
>>> On 2017-12-06 05:50, Michael Ellerman wrote:
>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>
>>>>> On Wed 29-11-17 14:25:36, Kees Cook wrote:
>>>>> It is safe in a sense it doesn't perform any address space dangerous
>>>>> operations. mmap is _inherently_ about the address space so the context
>>>>> should be kind of clear.
>>>>
>>>> So now you have to define what "dangerous" means.
>>>>
>>>>>> MAP_FIXED_UNIQUE
>>>>>> MAP_FIXED_ONCE
>>>>>> MAP_FIXED_FRESH
>>>>>
>>>>> Well, I can open a poll for the best name, but none of those you are
>>>>> proposing sound much better to me. Yeah, naming sucks...
>>>
>>> I also don't like the _SAFE name - MAP_FIXED in itself isn't unsafe [1],
>>> but I do agree that having a way to avoid clobbering (parts of) an
>>> existing mapping is quite useful. Since we're bikeshedding names, how
>>> about MAP_FIXED_EXCL, in analogy with the O_ flag.
>>
>> I really give up on the name discussion. I will take whatever the
>> majority comes up with. I just do not want this (useful) funtionality
>> get bikeched to death.
> 
> Yup, I really want this to land too. What do people think of Matthew
> Wilcox's MAP_REQUIRED ? MAP_EXACT isn't exact, and dropping "FIXED"
> out of the middle seems sensible to me.

+1, MAP_REQUIRED does sound like the best one so far, yes. Sorry if I contributed
to any excessive bikeshedding. :)

thanks,
john h

> 
> MIchael, any suggestions with your API hat on?
> 
> -Kees
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
