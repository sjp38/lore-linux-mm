Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0CF46B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:59:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v190so13307477wme.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:59:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n69si10372662wmd.101.2017.03.13.03.59.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 03:59:04 -0700 (PDT)
Date: Mon, 13 Mar 2017 11:59:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: strange allocation failures
Message-ID: <20170313105903.GM31518@dhcp22.suse.cz>
References: <CACT4Y+ZVWUYda9zr74QOmcXzd0S7P714LhzrVu7wRO0oDM0P2w@mail.gmail.com>
 <d849e961-7120-2ba5-1d58-df81d0ae3293@virtuozzo.com>
 <CACT4Y+Y=Pz6wFN66BGdPkTPJWrnbxCL2GX-R0q5_jr5kwjF+zA@mail.gmail.com>
 <CACT4Y+bD0S9CY0ahvZ=pOpXqHAkH6P0OTHPTeBi-Pb2Nw6ph4w@mail.gmail.com>
 <cac135d2-7ed4-c066-6316-22be9f7d16a3@virtuozzo.com>
 <CACT4Y+b7f5Q7c912b2Y0ohuKMDFp9p7QEhH-3HnwqPtunuzcRw@mail.gmail.com>
 <CACT4Y+Z0wwf3=mxUuZqn3M9qPBVhM6nRWi3hveeV2JPoubLAwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z0wwf3=mxUuZqn3M9qPBVhM6nRWi3hveeV2JPoubLAwA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 13-03-17 11:45:01, Dmitry Vyukov wrote:
> On Mon, Mar 13, 2017 at 11:37 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
[...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6cbde310abed..418c80a76b4a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3073,6 +3073,11 @@ static inline bool should_suppress_show_mem(void)
> >  #if NODES_SHIFT > 8
> >         ret = in_interrupt();
> 
> /\/\/\/\/\/\/\/\
> As a side note, looking at this line.
> Can vmalloc be called from an interrupt? If so, won't we fail all
> vmalloc's in an unlucky interrupt that hit a task with
> fatal_signal_pending?

__get_vm_area_node has a BUG_ON so I do not think this is allowed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
