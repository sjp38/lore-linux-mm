Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCBC88E0104
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 17:35:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so5840071edz.15
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 14:35:46 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y25si728311edv.448.2019.01.27.14.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 14:35:45 -0800 (PST)
Date: Sun, 27 Jan 2019 23:35:42 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
Message-ID: <nycvar.YFH.7.76.1901272335040.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com> <20190124002455.GA23181@nautica> <20190124124501.GA18012@nautica> <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, 24 Jan 2019, Jiri Kosina wrote:

> > Jiri, you've offered resubmitting the last two patches properly, can you 
> > incorporate this change or should I just send this directly? (I'd take 
> > most of your commit message and add your name somewhere)
> 
> I've been running some basic smoke testing with the kernel from
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git/log/?h=pagecache-sidechannel-v2
> 
> (attaching the respective two patches to apply on top of latest Linus' 
> tree to this mail as well), and everything looks good so far.

So, any objections to aproaching it this way?

I've not been able to spot any obvious breakage so far with it.

Thanks,

-- 
Jiri Kosina
SUSE Labs
