Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4576B0282
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:12:48 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r20so9702169wrg.23
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:12:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor6130522wra.28.2017.12.18.11.12.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 11:12:47 -0800 (PST)
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213093110.3550-1-mhocko@kernel.org>
 <20171213093110.3550-2-mhocko@kernel.org> <20171213125540.GA18897@amd>
 <20171213130458.GI25185@dhcp22.suse.cz> <20171213130900.GA19932@amd>
 <20171213131640.GJ25185@dhcp22.suse.cz> <20171213132105.GA20517@amd>
 <20171213144050.GG11493@rei>
 <CAGXu5jLqE6cUxk-Girx6PG7upEzz8jmu1OH_3LVC26iJc2vTxQ@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <c7c7a30e-a122-1bbf-88a2-3349d755c62d@gmail.com>
Date: Mon, 18 Dec 2017 20:12:41 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLqE6cUxk-Girx6PG7upEzz8jmu1OH_3LVC26iJc2vTxQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Cyril Hrubis <chrubis@suse.cz>
Cc: mtk.manpages@gmail.com, Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello Kees,

I'm late to the party, and only just caught up with the fuss :-).

On 12/14/2017 12:19 AM, Kees Cook wrote:
> On Wed, Dec 13, 2017 at 6:40 AM, Cyril Hrubis <chrubis@suse.cz> wrote:
>> Hi!
>>> You selected stupid name for a flag. Everyone and their dog agrees
>>> with that. There's even consensus on better name (and everyone agrees
>>> it is better than .._SAFE). Of course, we could have debate if it is
>>> NOREPLACE or NOREMOVE or ... and that would be bikeshed. This was just
>>> poor naming on your part.
>>
>> Well while everybody agrees that the name is so bad that basically
>> anything else would be better, there does not seem to be consensus on
>> which one to pick. I do understand that this frustrating and fruitless.
> 
> Based on the earlier threads where I tried to end the bikeshedding, it
> seemed like MAP_FIXED_NOREPLACE was the least bad option.
> 
>> So what do we do now, roll a dice to choose new name?
>>
>> Or do we ask BFDL[1] to choose the name?
> 
> I'd like to hear feedback from Michael Kerrisk, as he's had to deal
> with these kinds of choices in the past. I'm fine to ask Linus too. I
> just want to get past the name since the feature is quite valuable.
> 
> And if Michal doesn't want to touch this patch any more, I'm happy to
> do the search/replace/resend. :P

Something with the prefix MAP_FIXED_ seems to me obviously desirable,
both to suggest that the function is similar, and also for easy
grepping of the source code to look for instances of both.
MAP_FIXED_SAFE didn't really bother me as a name, but 
MAP_FIXED_NOREPLACE (or MAP_FIXED_NOCLOBBER) seem slightly more 
descriptive of what the flag actually does, so a little better.

Cheers,

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
