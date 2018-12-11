Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC8C38E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:03:50 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id f16so1550218lfc.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:03:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8-v6sor8142739ljj.23.2018.12.11.02.03.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 02:03:48 -0800 (PST)
Date: Tue, 11 Dec 2018 13:03:46 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] ksm: React on changing "sleep_millisecs" parameter faster
Message-ID: <20181211100346.GE2342@uranus.lan>
References: <154445792450.3178.16241744401215933502.stgit@localhost.localdomain>
 <20181210201036.GC2342@uranus.lan>
 <db19c148-b375-b6f2-dbf5-9e78f5e46c04@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db19c148-b375-b6f2-dbf5-9e78f5e46c04@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com

On Tue, Dec 11, 2018 at 12:23:11PM +0300, Kirill Tkhai wrote:
...
> > Kirill, can we rather reuse @ksm_thread variable from ksm_init
> > (by moving it to static file level variable).
> 
> I've considered using it, but this is not looks good for me.
> The problem is ksm thread may be parked, or it even may fail
> to start. But at the same time, parallel writes to "sleep_millisecs"
> are possible. There is a place for races, so to use the local
> variable in ksm_init() (like we have at the moment) looks better
> for me. At the patch the mutex protects against any races.
> 
> > Also wakening up
> > unconditionally on write looks somehow suspicious to me
> > though I don't have a precise argument against.
> 
> The conditional wait requires one more wait_queue. This is
> the thing I tried to avoid. But. I also had doubts about
> this, so you are already the second person, who worries :)
> It looks like we really need to change this.
> 
> How are you about something like the below?

I see. The code below looks a way better for me, thanks!
