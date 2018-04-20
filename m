Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFA886B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 03:55:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e14so4244213pfi.9
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 00:55:34 -0700 (PDT)
Received: from sonic306-19.consmr.mail.gq1.yahoo.com (sonic306-19.consmr.mail.gq1.yahoo.com. [98.137.68.82])
        by mx.google.com with ESMTPS id p1-v6si5114004pld.412.2018.04.20.00.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 00:55:33 -0700 (PDT)
Date: Fri, 20 Apr 2018 07:55:29 +0000 (UTC)
From: Thierry <reserv0@yahoo.com>
Reply-To: Thierry <reserv0@yahoo.com>
Message-ID: <234273956.1792577.1524210929280@mail.yahoo.com>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
References: <234273956.1792577.1524210929280.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, reserv0@yahoo.com

On Thu, 4/19/18, Andrew Morton <akpm@linux-foundation.org> wrote:

> (switched to email.=C2=A0 Please respond via emailed reply-to-all, not vi=
a the
> bugzilla web interface).
>
> https://bugzilla.kernel.org/show_bug.cgi?id=3D196157
>
> People are still hurting from this.=C2=A0 It does seem a pretty major
> regression for highmem machines.
>
> I'm surprised that we aren't hearing about this from distros.=C2=A0 Maybe=
 it
> only affects a subset of highmem machines?

Supposition: it would only affect distros with a given glibc version (my
affected machines run glibc v2.13) ?

Please, also take note that I encountered this bug on the 64 bits flavor of=
 the
same distro (Rosa 2012), on 64 bits capable machines, with Linux v4.2+ and
until Linux v4.8.4 was released (and another interesting fact is that anoth=
er
64 bits distro one the same machines was not affected at all by that bug,
which would reinforce my suspicion about a glibc-triggered and
glibc-version-dependent bug).

> Anyway, can we please take another look at it?=C2=A0 Seems that we messed=
 up
> highmem dirty pagecache handling in the 4.2 timeframe.

Oh, yes, please, do have a look ! :-D

In the mean time, could you guys also consider extending the lifetime of th=
e
v4.1 kernel until this ***showstopper*** bug is resolved in the mainline ke=
rnel
version ?

Many (many, many, many) thanks in advance !
