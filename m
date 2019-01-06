Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 824B98E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 06:33:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so30000947pll.0
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 03:33:40 -0800 (PST)
Received: from aws.guarana.org (aws.guarana.org. [13.237.110.252])
        by mx.google.com with ESMTPS id v16si5465301pgc.519.2019.01.06.03.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 06 Jan 2019 03:33:38 -0800 (PST)
Date: Sun, 6 Jan 2019 11:33:36 +0000
From: Kevin Easton <kevin@guarana.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190106113336.GA31214@ip-172-31-15-78>
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

On Sat, Jan 05, 2019 at 01:54:03PM -0800, Linus Torvalds wrote:
> On Sat, Jan 5, 2019 at 12:43 PM Jiri Kosina <jikos@kernel.org> wrote:
> >
> > > Who actually _uses_ mincore()? That's probably the best guide to what
> > > we should do. Maybe they open the file read-only even if they are the
> > > owner, and we really should look at file ownership instead.
> >
> > Yeah, well
> >
> >         https://codesearch.debian.net/search?q=mincore
> >
> > is a bit too much mess to get some idea quickly I am afraid.

> Anyway, the Debian code search just results in mostly non-present
> stuff. It's sad that google code search is no more. It was great for
> exactly these kinds of questions.

If you select the "Group search results by Debian source package"
option on the search results page it makes it a lot easier to skim
through.

It looks to me like Firefox is expecting mincore() not to fail on
libraries that it has mapped:

https://sources.debian.org/src/firefox-esr/60.4.0esr-1/mozglue/linker/BaseElf.cpp/?hl=98#L98

    - Kevin
> 
> The mono runtime seems to have some mono_pages_not_faulted() function,
> but I don't know if people use it for file mappings, and I couldn't
> find any interesting users of it.
> 
> I didn't find anything that seems to really care, but I gave up after
> a few pages of really boring stuff.
> 
>                     Linus
> 
> 
