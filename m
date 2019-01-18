Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B10328E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:23:07 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id h3so6984055ywc.20
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:23:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e83sor1982526ybe.38.2019.01.18.06.23.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 06:23:05 -0800 (PST)
Date: Fri, 18 Jan 2019 06:23:02 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190118142302.GC50184@devbig004.ftw2.facebook.com>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
 <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
 <CAHk-=wgrSKyN23yp-npq6+J-4pGqbzxb3mJ183PryjHw7PWDyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgrSKyN23yp-npq6+J-4pGqbzxb3mJ183PryjHw7PWDyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jiri Kosina <jikos@kernel.org>, Masatake YAMATO <yamato@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

Hello, Linus.

On Sat, Jan 05, 2019 at 01:54:03PM -0800, Linus Torvalds wrote:
> And the first hit is 'fincore', which probably nobody cares about
> anyway, but it does
> 
>     fd = open (name, O_RDONLY)
>     ..
>     mmap(window, len, PROT_NONE, MAP_PRIVATE, ..

So, folks here have been using fincore(1) for diagnostic purposes and
are also looking to expand on it to investigate per-cgroup cache
usages (mmap -> mincore -> /proc/self/pagemap -> /proc/kpagecgroup ->
cgroup path).

These are all root-only usages to find out what's going on with the
whole page cache.  We aren't attached to doing things this particular
way but it'd suck if there's no way.

Thanks.

-- 
tejun
