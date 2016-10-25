Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4F96B0266
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 10:11:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so5026036wme.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 07:11:00 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g8si167502wjv.233.2016.10.25.07.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 07:10:58 -0700 (PDT)
Date: Tue, 25 Oct 2016 10:10:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: do not recurse in direct reclaim
Message-ID: <20161025141050.GA13019@cmpxchg.org>
References: <20161024203005.5547-1-hannes@cmpxchg.org>
 <20161025090747.GD31137@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025090747.GD31137@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 25, 2016 at 11:07:47AM +0200, Michal Hocko wrote:
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you.

> I would prefer to have the PF_MEMALLOC condition in a check on its own
> with a short explanation that we really do not want to recurse to the
> reclaim due to stack overflows.

Okay, fair enough. I also added why we prefer temporarily breaching
the limit over failing the allocation. How is this?
