Received: by ug-out-1314.google.com with SMTP id c2so570824ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 23:23:03 -0700 (PDT)
Message-ID: <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
Date: Thu, 26 Jul 2007 13:23:03 +0700
From: "Andika Triwidada" <andika@gmail.com>
Subject: Re: updatedb
In-Reply-To: <46A81C39.4050009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
	 <46A81C39.4050009@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/07, Rene Herman <rene.herman@gmail.com> wrote:
> On 07/25/2007 07:15 PM, Robert Deaton wrote:
>
> > On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:
>
> >> And there we go again -- off into blabber-land. Why does swap-prefetch
> >> help updatedb? Or doesn't it? And if it doesn't, why should anyone
> >> trust anything else someone who said it does says?
>
> > I don't think anyone has ever argued that swap-prefetch directly helps
> > the performance of updatedb in any way
>
> People have argued (claimed, rather) that swap-prefetch helps their system
> after updatedb has run -- you are doing so now.
>
> > however, I do recall people mentioning that updatedb, being a ram
> > intensive task, will often cause things to be swapped out while it runs
> > on say a nightly cronjob.
>
> Problem spot no. 1.
>
> RAM intensive? If I run updatedb here, it never grows itself beyond 2M. Yes,
> two. I'm certainly willing to accept that me and my systems are possibly not
> the reference but assuming I'm _very_ special hasn't done much for me either
> in the past.

Might be insignificant, but updatedb calls find (~2M) and sort (~26M).
Definitely not RAM intensive though (RAM is 1GB).

>
> The thing updatedb does do, or at least has the potential to do, is fill
> memory with cached inodes/dentries but Linux does not swap to make room for
> caches. So why will updatedb "often cause things to be swapped out"?
>

[ snip ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
