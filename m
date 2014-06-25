Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 11F646B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:28:07 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id c1so6475177igq.9
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 13:28:06 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id mo4si7684430icc.63.2014.06.25.13.28.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 13:28:06 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Wed, 25 Jun 2014 13:27:53 -0700
Subject: RE: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
 interfaces
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E341D585503@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
 <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
 <20140625201603.GA1534@t510.redhat.com>
In-Reply-To: <20140625201603.GA1534@t510.redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: Rafael Aquini [mailto:aquini@redhat.com]
> Sent: Wednesday, June 25, 2014 4:16 PM
> To: Motohiro Kosaki
> Cc: linux-mm@kvack.org; Andrew Morton; Rik van Riel; Mel Gorman; Johannes=
 Weiner; Motohiro Kosaki JP; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() in=
terfaces
>=20
> On Wed, Jun 25, 2014 at 12:41:17PM -0700, Motohiro Kosaki wrote:
> >
> >
> > > -----Original Message-----
> > > From: Rafael Aquini [mailto:aquini@redhat.com]
> > > Sent: Wednesday, June 25, 2014 2:40 PM
> > > To: linux-mm@kvack.org
> > > Cc: Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner;
> > > Motohiro Kosaki JP; linux-kernel@vger.kernel.org
> > > Subject: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
> > > interfaces
> > >
> > > This patch leverages the addition of explicit accounting for pages
> > > used by shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem vmstat"
> > > -- in order to make the users of sysinfo(2) and si_meminfo*() friends=
 aware of that vmstat entry consistently across the interfaces.
> >
> > Why?
>=20
> Because we do not report consistently across the interfaces we declare ex=
porting that data. Check sysinfo(2) manpage, for instance:
> [...]
>            struct sysinfo {
>                long uptime;             /* Seconds since boot */
>                unsigned long loads[3];  /* 1, 5, and 15 minute load avera=
ges */
>                unsigned long totalram;  /* Total usable main memory size =
*/
>                unsigned long freeram;   /* Available memory size */
>                unsigned long sharedram; /* Amount of shared memory */ <<<=
<< [...]
>=20
> userspace tools resorting to sysinfo() syscall will get a hardcoded 0 for=
 shared memory which is reported differently from
> /proc/meminfo.
>=20
> Also, si_meminfo() & si_meminfo_node() are utilized within the kernel to =
gather statistics for /proc/meminfo & friends, and so we
> can leverage collecting sharedmem from those calls as well, just as we do=
 for totalram, freeram & bufferram.

But "Amount of shared memory"  didn't mean amout of shmem. It actually mean=
t amout of page of page-count>=3D2.
Again, there is a possibility to change the semantics. But I don't have eno=
ugh userland knowledge to do. Please investigate
and explain why your change don't break any userland.=20






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
