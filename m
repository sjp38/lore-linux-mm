Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 89B896B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:00:29 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l65so62364236wmf.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:00:29 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id ft10si159992957wjc.19.2016.01.06.07.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 07:00:28 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id l65so62363398wmf.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:00:27 -0800 (PST)
Date: Wed, 6 Jan 2016 16:00:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20160106150025.GD13900@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <CAP=VYLoGcqXvX8ORTmLH9u5s3p2u5f7qqBy14-U4gUdRTF6C5g@mail.gmail.com>
 <20160106091027.GA13900@dhcp22.suse.cz>
 <20160106142611.GD2957@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160106142611.GD2957@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 06-01-16 09:26:12, Paul Gortmaker wrote:
> [Re: [PATCH 1/2] mm, oom: introduce oom reaper] On 06/01/2016 (Wed 10:10) Michal Hocko wrote:
> 
> > On Mon 21-12-15 15:38:21, Paul Gortmaker wrote:
> > [...]
> > > ...use one of the non-modular initcalls here?   I'm trying to clean up most of
> > > the non-modular uses of modular macros etc. since:
> > > 
> > >  (1) it is easy to accidentally code up an unused module_exit function
> > >  (2) it can be misleading when reading the source, thinking it can be
> > >       modular when the Makefile and/or Kconfig prohibit it
> > >  (3) it requires the include of the module.h header file which in turn
> > >      includes nearly everything else, thus increasing CPP overhead.
> > > 
> > > I figured no point in sending a follow on patch since this came in via
> > > the akpm tree into next and that gets rebased/updated regularly.
> > 
> > Sorry for the late reply. I was mostly offline throughout the last 2
> > weeks last year. Is the following what you would like to see? If yes I
> > will fold it into the original patch.
> 
> Yes, that looks fine.  Do note that susbsys_initcall is earlier than the
> module_init that you were using previously though.

Yes, I have noticed that but quite honestly module_init choice was just
"look around and use what others are doing". So there was no particular
reason to stick with that order.

Thanks for double checking after me!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
