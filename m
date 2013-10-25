Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 647B86B0098
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 15:43:12 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so4844417pbb.28
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 12:43:12 -0700 (PDT)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id gw3si5951221pac.56.2013.10.25.12.43.10
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 12:43:11 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id l12so1647708wiv.2
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 12:43:08 -0700 (PDT)
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Date: Fri, 25 Oct 2013 21:40:13 +0200
Message-ID: <1999200.Zdacx0scmY@diego-arch>
In-Reply-To: <154617470.12445.1382725583671.JavaMail.mail@webmail11>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07> <alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz> <154617470.12445.1382725583671.JavaMail.mail@webmail11>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: david@lang.hm, neilb@suse.de, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

El Viernes, 25 de octubre de 2013 18:26:23 Artem S. Tashkinov escribi=F3=
:
> Oct 25, 2013 05:26:45 PM, david wrote:
> >actually, I think the problem is more the impact of the huge write l=
ater
> >on.
> Exactly. And not being able to use applications which show you IO
> performance like Midnight Commander. You might prefer to use "cp -a" =
but I
> cannot imagine my life without being able to see the progress of a co=
pying
> operation. With the current dirty cache there's no way to understand =
how
> you storage media actually behaves.


This is a problem I also have been suffering for a long time. It's not =
so much=20
how much and when the systems syncs dirty data, but how unreponsive the=
=20
desktop becomes when it happens (usually, with rsync + large files). Mo=
st=20
programs become completely unreponsive, specially if they have a large =
memory=20
consumption (ie. the browser). I need to pause rsync and wait until the=
=20
systems writes out all dirty data if I want to do simple things like sc=
rolling=20
or do any action that uses I/O, otherwise I need to wait minutes.

I have 16 GB of RAM and excluding the browser (which usually uses about=
 half=20
of a GB) and KDE itself, there are no memory hogs, so it seem like it's=
=20
something that shouldn't happen. I can understand that I/O operations a=
re=20
laggy when there is some other intensive I/O ongoing, but right now the=
 system=20
becomes completely unreponsive. If I am unlucky and Konsole also become=
s=20
unreponsive, I need to switch to a VT (which also takes time).

I haven't reported it before in part because I didn't know how to do it=
, "my=20
browser stalls" is not a very useful description and I didn't know what=
 kind=20
of data I'm supposed to report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
