Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id B9E3C6B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 11:05:58 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id q1so3017631lam.22
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 08:05:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba16si35256799lab.35.2014.10.16.08.05.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 08:05:57 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:05:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] kernel: res_counter: remove the unused API
Message-ID: <20141016150553.GA26234@dhcp22.suse.cz>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
 <1413251163-8517-4-git-send-email-hannes@cmpxchg.org>
 <1413444034.2128.27.camel@x220>
 <20141016112021.GC338@dhcp22.suse.cz>
 <20141016144641.GC9180@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016144641.GC9180@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Bolle <pebolle@tiscali.nl>, Valentin Rothberg <valentinrothberg@gmail.com>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-10-14 10:46:41, Johannes Weiner wrote:
> On Thu, Oct 16, 2014 at 01:20:21PM +0200, Michal Hocko wrote:
> > On Thu 16-10-14 09:20:34, Paul Bolle wrote:
> > > On Mon, 2014-10-13 at 21:46 -0400, Johannes Weiner wrote:
> > > > All memory accounting and limiting has been switched over to the
> > > > lockless page counters.  Bye, res_counter!
> > > > 
> > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > Acked-by: Vladimir Davydov <vdavydov@parallels.com>
> > > > Acked-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > > This patch landed in today's linux-next (ie, next 20141016).
> > > 
> > > >  Documentation/cgroups/resource_counter.txt | 197 -------------------------
> > > >  include/linux/res_counter.h                | 223 -----------------------------
> > > >  init/Kconfig                               |   6 -
> > > >  kernel/Makefile                            |   1 -
> > > >  kernel/res_counter.c                       | 211 ---------------------------
> > > >  5 files changed, 638 deletions(-)
> > > >  delete mode 100644 Documentation/cgroups/resource_counter.txt
> > > >  delete mode 100644 include/linux/res_counter.h
> > > >  delete mode 100644 kernel/res_counter.c
> > > 
> > > There's a last reference to CONFIG_RESOURCE_COUNTERS in
> > > Documentation/cgroups/memory.txt. That reference could be dropped too,
> > > couldn't it?
> > ---
> > From a54e375e85c814199f480cb4ee7a133a395c5a00 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 16 Oct 2014 13:15:24 +0200
> > Subject: [PATCH] kernel-res_counter-remove-the-unused-api-fix
> > 
> > ditch the last remainings of res_counter
> > 
> > Reported-by: Paul Bolle <pebolle@tiscali.nl>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> That makes sense, although that document is still littered with
> out-of-date and seemingly irrelevant information, which is why I
> didn't bother to update it.

I would also prefer to re-write or remove it long term.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
