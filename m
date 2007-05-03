Received: by nz-out-0506.google.com with SMTP id f1so579838nzc
        for <linux-mm@kvack.org>; Thu, 03 May 2007 09:15:09 -0700 (PDT)
Message-ID: <6bffcb0e0705030915r7c169f1cnd3b21413255a5c1f@mail.gmail.com>
Date: Thu, 3 May 2007 18:15:06 +0200
From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
In-Reply-To: <20070503155407.GA7536@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <20070503155407.GA7536@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 03/05/07, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Andrew Morton <akpm@linux-foundation.org> wrote:
>
> > - If replying, please be sure to cc the appropriate individuals.
> >   Please also consider rewriting the Subject: to something
> >   appropriate.
>
> i'm wondering about swap-prefetch:
>
>   mm-implement-swap-prefetching.patch
>   swap-prefetch-avoid-repeating-entry.patch
>   add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated-swap-prefetch.patch
>
> The swap-prefetch feature is relatively compact:
>
>    10 files changed, 745 insertions(+), 1 deletion(-)
>
> it is contained mostly to itself:
>
>    mm/swap_prefetch.c            |  581 ++++++++++++++++++++++++++++++++
>
> i've reviewed it once again and in the !CONFIG_SWAP_PREFETCH case it's a
> clear NOP, while in the CONFIG_SWAP_PREFETCH=y case all the feedback
> i've seen so far was positive. Time to have this upstream and time for a
> desktop-oriented distro to pick it up.
>
> I think this has been held back way too long. It's .config selectable
> and it is as ready for integration as it ever is going to be. So it's a
> win/win scenario.

I'm using SWAP_PREFETCH since 2.6.17-mm1 (I don't have earlier configs)
http://www.stardust.webpages.pl/files/tbf/euridica/2.6.17-mm1/mm-config
and I don't recall _any_ problems. It's very stable for me.

>
> Acked-by: Ingo Molnar <mingo@elte.hu>
>
>         Ingo

Regards,
Michal

-- 
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
