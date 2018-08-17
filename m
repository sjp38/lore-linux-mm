Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 809AA6B07DA
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 07:29:49 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 22-v6so6977900ita.3
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 04:29:49 -0700 (PDT)
Received: from sonic302-21.consmr.mail.ne1.yahoo.com (sonic302-21.consmr.mail.ne1.yahoo.com. [66.163.186.147])
        by mx.google.com with ESMTPS id u26-v6si1402778jaa.125.2018.08.17.04.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 04:29:48 -0700 (PDT)
Date: Fri, 17 Aug 2018 11:29:45 +0000 (UTC)
From: Thierry <reserv0@yahoo.com>
Reply-To: Thierry <reserv0@yahoo.com>
Message-ID: <1978465524.8206495.1534505385491@mail.yahoo.com>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
References: <1978465524.8206495.1534505385491.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry <reserv0@yahoo.com>, Michal Hocko <mhocko@kernel.org>
Cc: Alkis Georgopoulos <alkisg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 8/17/18, Michal Hocko <mhocko@kernel.org> wrote:

> Have you tried to set highmem_is_dirtyable as suggested elsewhere?

I tried everything, and yes, that too, to no avail. The only solution is to limit the
available RAM to less than 12Gb, which is just unacceptable for me.
 
> I would like to stress out that 16GB with 32b kernels doesn't play really nice.

I would like to stress out that 32 Gb of RAM played totally nice and very smoothly
with v4.1 and older kernels... This got broken in v4.2 and never repaired since.
This is a very nasty regression, and my suggestion to keep v4.1 maintained till
that regression would finally get worked around fell into deaf ears...

> Even small changes (larger kernel memory footprint) can lead to all sorts of
> problems. I would really recommend using 64b kernels instead. There shouldn't be
> any real reason to stick with 32bhighmem based  kernel for such a large beast.
> I strongly doubt the cpu itself would be 32b only.

The reasons are many (one of them dealing with being able to run old 32 bits
Linux distros but without the bugs and security flaws of old, unmaintained kernels).

But the reasons are not the problem here. The problem is that v4.2 introduced a
bug (*) that was never fixed since.

A shame, really. :-(

(*) and that bug also affected 64 bits kernels, at first, mind you, till v4.8.4 got
released; see my comment in my initial report here:
https://bugzilla.kernel.org/show_bug.cgi?id=110031#c14
