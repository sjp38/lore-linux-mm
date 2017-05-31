Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B868C6B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:21:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x184so3598791wmf.14
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:21:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o23si17353626wra.77.2017.05.31.08.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 08:21:53 -0700 (PDT)
Date: Wed, 31 May 2017 17:21:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Patch v2] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170531152151.GT27783@dhcp22.suse.cz>
References: <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510082734.2055-1-nick.desaulniers@gmail.com>
 <20170510083844.GG31466@dhcp22.suse.cz>
 <20170516082746.GA2481@dhcp22.suse.cz>
 <20170526044343.autu63rpfigbzhyi@lostoracle.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170526044343.autu63rpfigbzhyi@lostoracle.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 25-05-17 21:43:43, Nick Desaulniers wrote:
> On Tue, May 16, 2017 at 10:27:46AM +0200, Michal Hocko wrote:
> > I guess it is worth reporting this to clang bugzilla. Could you take
> > care of that Nick?
> 
> >From https://bugs.llvm.org//show_bug.cgi?id=33065#c5
> it seems that this is indeed a sequence bug in the previous version of
> this code and not a compiler bug.  You can read that response for the
> properly-cited wording but my TL;DR/understanding is for the given code:
> 
> struct foo bar = {
>   .a = (c = 0),
>   .b = c,
> };
> 
> That the compiler is allowed to reorder the initializations of bar.a and
> bar.b, so what the value of c here might not be what you expect.

This is interesting because what I hear from our gcc people is something
different. I am not in a possition to argue here, though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
