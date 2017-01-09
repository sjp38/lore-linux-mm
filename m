Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8A916B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:42:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d142so8081368wmd.3
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:42:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e22si8374728wrc.236.2017.01.09.06.42.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 06:42:00 -0800 (PST)
Date: Mon, 9 Jan 2017 15:41:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: weird allocation pattern in alloc_ila_locks
Message-ID: <20170109144158.GM7495@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz>
 <20170106100433.GH5556@dhcp22.suse.cz>
 <20170106121642.GJ5556@dhcp22.suse.cz>
 <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170107092746.GC5047@dhcp22.suse.cz>
 <CANn89iL7JTkV_r9Wqqcrsz1GJmTfWtxD1TUV1YOKsv3rwN-+vQ@mail.gmail.com>
 <20170109095828.GE7495@dhcp22.suse.cz>
 <CANn89iLoC6uL8rfr_GWfuPeKasgw=JiuciSDN6EQBC0yFsgbww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iLoC6uL8rfr_GWfuPeKasgw=JiuciSDN6EQBC0yFsgbww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-01-17 06:31:50, Eric Dumazet wrote:
> On Mon, Jan 9, 2017 at 1:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> >
> > Also this seems to be an init code so I assume a modprobe would have to
> > set a non-default policy to make use of it. Does anybody do that out
> > there?
> 
> This is not init code. Whole point of rhashtable is that the resizes
> can happen anytime.
> At boot time, most rhashtable would be tiny.
> Then, when load permits, hashtables grow in size.

OK, we are mixing two things here. I was talking about alloc_ila_locks
which is an init code AFAIU.

If you are talking about alloc_bucket_locks then I would argue that the
current code doesn't work as expected as the rehash happens from a
kernel worker context and so the numa policy is out of control.

I will reply to this email with the patches I have pending here and plan
to post just to make sure we are at the same page.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
