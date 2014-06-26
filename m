Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 68D686B003C
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 20:12:41 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wm4so2996204obc.20
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 17:12:41 -0700 (PDT)
Received: from mail-oa0-x22f.google.com (mail-oa0-x22f.google.com [2607:f8b0:4003:c02::22f])
        by mx.google.com with ESMTPS id h8si7403289oed.31.2014.06.25.17.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 17:12:40 -0700 (PDT)
Received: by mail-oa0-f47.google.com with SMTP id n16so3017047oag.6
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 17:12:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140625225451.GB1534@t510.redhat.com>
References: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
 <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
 <20140625201603.GA1534@t510.redhat.com> <6B2BA408B38BA1478B473C31C3D2074E341D585503@SV-EXCHANGE1.Corp.FC.LOCAL>
 <20140625225451.GB1534@t510.redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 25 Jun 2014 20:12:20 -0400
Message-ID: <CAHGf_=qahsLFA4763KzFf5CgvgcE1cjxJrzNafQR49-cNJZKuw@mail.gmail.com>
Subject: Re: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() interfaces
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> I agree that reporting the amount of shared pages in that historically fashion
> might not be interesting for userspace tools resorting to sysinfo(2),
> nowadays.
>
> OTOH, our documentation implies we do return shared memory there, and FWIW,
> considering the other places we do export the "shared memory" concept to
> userspace nowadays, we are suggesting it's the amount of tmpfs/shmem, and not the
> amount of shared mapped pages it historiacally represented once. What is really
> confusing is having a field that supposedely/expectedely would return the amount
> of shmem to userspace queries, but instead returns a hard-coded zero (0).
>
> I could easily find out that there were some user complaint/confusion on this
> semantic inconsistency in the past, as in:
> https://groups.google.com/forum/#!topic/comp.os.linux.development.system/ogWVn6XdvGA
>
> or in:
> http://marc.info/?l=net-snmp-cvs&m=132148788500667
>
> which suggests users seem to always have understood it as being shmem/tmpfs
> usage, as the /proc/meminfo field "MemShared" was tied direclty to
> sysinfo.sharedram. Historically we reported shared memory that way, and
> when it wasn't accurately meaning that anymore a 0 was hardcoded there to
> potentially not break compatibility with older tools (older than 2.4).
> In 2.6 we got rid of meminfo's "MemShared" until 2009, when you sort of
> re-introduced it re-branded as Shmem. IMO, we should leverage what we
> have in kernel now and take this change to make the exposed data consistent
> across the interfaces that export it today -- sysinfo(2) & /proc/meminfo.
>
> This is not a hard requirement, though, but rather a simple maintenance
> nitpick from code review.

Ok, ack then. But please update a patch description and repost w/
ccing linux-api@vger.kernel.org. Someone might have a specific concern
about a compatibility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
