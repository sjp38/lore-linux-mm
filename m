Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6D06B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 07:20:26 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so2617622lbg.32
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 04:20:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id zs1si27345110lbb.27.2014.10.16.04.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 04:20:24 -0700 (PDT)
Date: Thu, 16 Oct 2014 13:20:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] kernel: res_counter: remove the unused API
Message-ID: <20141016112021.GC338@dhcp22.suse.cz>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
 <1413251163-8517-4-git-send-email-hannes@cmpxchg.org>
 <1413444034.2128.27.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413444034.2128.27.camel@x220>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Paul Bolle <pebolle@tiscali.nl>, Valentin Rothberg <valentinrothberg@gmail.com>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-10-14 09:20:34, Paul Bolle wrote:
> On Mon, 2014-10-13 at 21:46 -0400, Johannes Weiner wrote:
> > All memory accounting and limiting has been switched over to the
> > lockless page counters.  Bye, res_counter!
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Vladimir Davydov <vdavydov@parallels.com>
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> This patch landed in today's linux-next (ie, next 20141016).
> 
> >  Documentation/cgroups/resource_counter.txt | 197 -------------------------
> >  include/linux/res_counter.h                | 223 -----------------------------
> >  init/Kconfig                               |   6 -
> >  kernel/Makefile                            |   1 -
> >  kernel/res_counter.c                       | 211 ---------------------------
> >  5 files changed, 638 deletions(-)
> >  delete mode 100644 Documentation/cgroups/resource_counter.txt
> >  delete mode 100644 include/linux/res_counter.h
> >  delete mode 100644 kernel/res_counter.c
> 
> There's a last reference to CONFIG_RESOURCE_COUNTERS in
> Documentation/cgroups/memory.txt. That reference could be dropped too,
> couldn't it?
---
