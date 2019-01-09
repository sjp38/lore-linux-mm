Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1858E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 23:05:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y27so5062693qkj.21
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 20:05:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor33851700qkc.125.2019.01.08.20.04.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 20:04:59 -0800 (PST)
MIME-Version: 1.0
References: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
 <20190107095229.uvfuxpglreibxlo4@mbp>
In-Reply-To: <20190107095229.uvfuxpglreibxlo4@mbp>
From: Nathan Royce <nroycea+kernel@gmail.com>
Date: Tue, 8 Jan 2019 22:04:47 -0600
Message-ID: <CALaQ_hq-Ba_y1R2xozdJu2ywAitFQd6VsWB2g+FWqm3um=TbJw@mail.gmail.com>
Subject: Re: kmemleak: Cannot allocate a kmemleak_object structure - Kernel 4.19.13
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

I'm not all that sure it was memory related based on my Sun, 6 Jan
2019 13:17:04 -0600 post.
You'll see the log entries at 3AM, and based on earlier entries I
likely went to sleep around 1AM which would mean any memory intense
applications (eg. virtual machine) would've been closed out.
I have 8GB RAM in my desktop.


On Mon, Jan 7, 2019 at 3:52 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Hi Nathan,
>
> On Tue, Jan 01, 2019 at 01:17:06PM -0600, Nathan Royce wrote:
> > I had a leak somewhere and I was directed to look into SUnreclaim
> > which was 5.5 GB after an uptime of a little over 1 month on an 8 GB
> > system. kmalloc-2048 was a problem.
> > I just had enough and needed to find out the cause for my lagging system.
> >
> > I finally upgraded from 4.18.16 to 4.19.13 and enabled kmemleak to
> > hunt for the culprit. I don't think a day had elapsed before kmemleak
> > crashed and disabled itself.
>
> Under memory pressure, kmemleak may fail to allocate memory. See this
> patch for an attempt to slightly improve things but it's not a proper
> solution:
>
> http://lkml.kernel.org/r/20190102180619.12392-1-cai@lca.pw
>
> --
> Catalin
