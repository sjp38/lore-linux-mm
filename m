Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id B9D8F6B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 05:39:10 -0400 (EDT)
Received: by lagr1 with SMTP id r1so29293374lag.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 02:39:09 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id sc4si708481lbb.99.2015.05.15.02.39.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 02:39:08 -0700 (PDT)
Message-ID: <5555BEB9.6000905@yandex-team.ru>
Date: Fri, 15 May 2015 12:39:05 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
References: <20150512090156.24768.2521.stgit@buzz>	<20150512094303.24768.10282.stgit@buzz>	<CAEVpBaLm9eicuFPmyRLa7GddLwtBJh3XzHT=fxj-h0YwwmXQOg@mail.gmail.com>	<55532CB0.6070400@yandex-team.ru> <CAEVpBa+r6AuB7hnCnTm8YKHzaj172q7Wy89yT=P_F6GQG-3-1A@mail.gmail.com>
In-Reply-To: <CAEVpBa+r6AuB7hnCnTm8YKHzaj172q7Wy89yT=P_F6GQG-3-1A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Williamson <mwilliamson@undo-software.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On 14.05.2015 21:50, Mark Williamson wrote:
> Hi Konstantin,
>
> On Wed, May 13, 2015 at 11:51 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> On 12.05.2015 15:05, Mark Williamson wrote:
> <snip>
>>>    1. I was hoping we'd be able to backport a compatible fix to older
>>> kernels that might adopt the pagemap permissions change.  Using the V2
>>> format flags rules out doing this for kernels that are too old to have
>>> soft-dirty, I think.
>>>
>>>    2. From our software's PoV, I feel it's worth noting that it doesn't
>>> strictly fix ABI compatibility, though I realise that's probably not
>>> your primary concern here.  We'll need to modify our code to write the
>>> clear_refs file but that change is OK for us if it's the preferred
>>> solution.
> <snip>
>> I prefer to backport v2 format (except soft-dirty bit and clear_refs)
>> into older kernels. Page-shift bits are barely used so nobody will see
>> the difference.
>
> My concern was whether a change to format would be acceptable to
> include in the various -stable kernels; they are already including the
> additional protections on pagemap, so we're starting to need our
> fallback mode in distributions.  Do you think that such a patch would
> be acceptable there?
>
> (As an application vendor we're likely to be particularly stuck with
> what the commercial distributions decide to ship, which is why I'm
> trying to keep an eye on this)
>
> I appreciate that this is a slightly administrative concern!  I
> definitely like the technical approach of this code and it seems to
> work fine for us.

I cannot guarantee that v2 format will be accepted into stable kernels
and into distributives. I'm not the gate keeper.

As a fallback probably you should invent some kind of suid helper
which gives you access to required information without exposing pfn.
For example: it gets pids and memory ranges as arguments and prints
bitmap of CoWed pages into stdout.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
