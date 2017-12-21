Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 144806B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:38:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k1so15918269pgq.2
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 04:38:43 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id r76si14932770pfl.194.2017.12.21.04.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 04:38:41 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
In-Reply-To: <CAGXu5jJ289R9koVoHmxcvUWr6XHSZR2p0qq3WtpNyN-iNSvrNQ@mail.gmail.com>
References: <20171213092550.2774-1-mhocko@kernel.org> <20171213093110.3550-1-mhocko@kernel.org> <20171213093110.3550-2-mhocko@kernel.org> <20171213125540.GA18897@amd> <20171213130458.GI25185@dhcp22.suse.cz> <20171213130900.GA19932@amd> <20171213131640.GJ25185@dhcp22.suse.cz> <20171213132105.GA20517@amd> <20171213144050.GG11493@rei> <CAGXu5jLqE6cUxk-Girx6PG7upEzz8jmu1OH_3LVC26iJc2vTxQ@mail.gmail.com> <c7c7a30e-a122-1bbf-88a2-3349d755c62d@gmail.com> <CAGXu5jJ289R9koVoHmxcvUWr6XHSZR2p0qq3WtpNyN-iNSvrNQ@mail.gmail.com>
Date: Thu, 21 Dec 2017 23:38:37 +1100
Message-ID: <87po78fe7m.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Cyril Hrubis <chrubis@suse.cz>, Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Kees Cook <keescook@chromium.org> writes:

> On Mon, Dec 18, 2017 at 11:12 AM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> Hello Kees,
>>
>> I'm late to the party, and only just caught up with the fuss :-).
>
> No worries!
>
>> On 12/14/2017 12:19 AM, Kees Cook wrote:
>>> On Wed, Dec 13, 2017 at 6:40 AM, Cyril Hrubis <chrubis@suse.cz> wrote:
>>>> Hi!
>>>>> You selected stupid name for a flag. Everyone and their dog agrees
>>>>> with that. There's even consensus on better name (and everyone agrees
>>>>> it is better than .._SAFE). Of course, we could have debate if it is
>>>>> NOREPLACE or NOREMOVE or ... and that would be bikeshed. This was just
>>>>> poor naming on your part.
>>>>
>>>> Well while everybody agrees that the name is so bad that basically
>>>> anything else would be better, there does not seem to be consensus on
>>>> which one to pick. I do understand that this frustrating and fruitless.
>>>
>>> Based on the earlier threads where I tried to end the bikeshedding, it
>>> seemed like MAP_FIXED_NOREPLACE was the least bad option.
>>>
>>>> So what do we do now, roll a dice to choose new name?
>>>>
>>>> Or do we ask BFDL[1] to choose the name?
>>>
>>> I'd like to hear feedback from Michael Kerrisk, as he's had to deal
>>> with these kinds of choices in the past. I'm fine to ask Linus too. I
>>> just want to get past the name since the feature is quite valuable.
>>>
>>> And if Michal doesn't want to touch this patch any more, I'm happy to
>>> do the search/replace/resend. :P
>>
>> Something with the prefix MAP_FIXED_ seems to me obviously desirable,
>> both to suggest that the function is similar, and also for easy
>> grepping of the source code to look for instances of both.
>> MAP_FIXED_SAFE didn't really bother me as a name, but
>> MAP_FIXED_NOREPLACE (or MAP_FIXED_NOCLOBBER) seem slightly more
>> descriptive of what the flag actually does, so a little better.
>
> Great, thanks!
>
> Andrew, can you s/MAP_FIXED_SAFE/MAP_FIXED_NOREPLACE/g in the series?

This seems to have not happened. Presumably Andrew just missed the mail
in the flood. And will probably miss this one too ... :)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
