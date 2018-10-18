Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC2186B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 05:12:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1-v6so18238051eds.15
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:12:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12-v6si209122edx.446.2018.10.18.02.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 02:12:52 -0700 (PDT)
Date: Thu, 18 Oct 2018 11:12:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Convert mem_cgroup_id::ref to refcount_t type
Message-ID: <20181018091250.GA18839@dhcp22.suse.cz>
References: <153910718919.7006.13400779039257185427.stgit@localhost.localdomain>
 <20181016124939.GA13278@andrea>
 <a990eed4-611b-8464-c2aa-56684fee0ee5@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a990eed4-611b-8464-c2aa-56684fee0ee5@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 16-10-18 16:19:40, Kirill Tkhai wrote:
> Hi, Andrea,
> 
> On 16.10.2018 15:49, Andrea Parri wrote:
> > Hi Kirill,
> > 
> > On Tue, Oct 09, 2018 at 08:46:56PM +0300, Kirill Tkhai wrote:
> >> This will allow to use generic refcount_t interfaces
> >> to check counters overflow instead of currently existing
> >> VM_BUG_ON(). The only difference after the patch is
> >> VM_BUG_ON() may cause BUG(), while refcount_t fires
> >> with WARN().
> > 
> > refcount_{sub_and_test,inc_not_zero}() are documented to provide
> > "slightly" more relaxed ordering than their atomic_* counterpart,
> > c.f.,
> > 
> >   Documentation/core-api/refcount-vs-atomic.rst
> >   lib/refcount.c (inline comments)
> > 
> > IIUC, this semantic change won't cause problems here (but please
> > double-check? ;D ).
> 
> I just don't see a place, where we may think about using a modification
> of struct mem_cgroup::id::ref as a memory barrier to order something,
> and all this looks safe for me.

If there was any it would surely be unintentional. memcg->id.ref is a clear
reference counter pattern for the id lifetime.
-- 
Michal Hocko
SUSE Labs
