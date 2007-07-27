Received: by wa-out-1112.google.com with SMTP id m33so849191wag
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 17:46:15 -0700 (PDT)
Message-ID: <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>
Date: Fri, 27 Jul 2007 02:46:11 +0200
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: updatedb
In-Reply-To: <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
	 <46A81C39.4050009@gmail.com>
	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andika Triwidada <andika@gmail.com>
Cc: Rene Herman <rene.herman@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 26/07/07, Andika Triwidada <andika@gmail.com> wrote:
> On 7/26/07, Rene Herman <rene.herman@gmail.com> wrote:
> > On 07/25/2007 07:15 PM, Robert Deaton wrote:
> >
> > > On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:
> >
> > >> And there we go again -- off into blabber-land. Why does swap-prefetch
> > >> help updatedb? Or doesn't it? And if it doesn't, why should anyone
> > >> trust anything else someone who said it does says?
> >
> > > I don't think anyone has ever argued that swap-prefetch directly helps
> > > the performance of updatedb in any way
> >
> > People have argued (claimed, rather) that swap-prefetch helps their system
> > after updatedb has run -- you are doing so now.
> >
> > > however, I do recall people mentioning that updatedb, being a ram
> > > intensive task, will often cause things to be swapped out while it runs
> > > on say a nightly cronjob.
> >
> > Problem spot no. 1.
> >
> > RAM intensive? If I run updatedb here, it never grows itself beyond 2M. Yes,
> > two. I'm certainly willing to accept that me and my systems are possibly not
> > the reference but assuming I'm _very_ special hasn't done much for me either
> > in the past.
>
> Might be insignificant, but updatedb calls find (~2M) and sort (~26M).
> Definitely not RAM intensive though (RAM is 1GB).
>

That doesn't match my box at all :

root@dragon:/home/juhl# free
             total       used       free     shared    buffers     cached
Mem:       2070856    1611548     459308          0      59312     740760
-/+ buffers/cache:     811476    1259380
Swap:       987988          0     987988

root@dragon:/home/juhl# updatedb

root@dragon:/home/juhl# free
             total       used       free     shared    buffers     cached
Mem:       2070856    1724204     346652          0     144708     745328
-/+ buffers/cache:     834168    1236688
Swap:       987988          0     987988


This is a Slackware Linux 12.0 system.


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
