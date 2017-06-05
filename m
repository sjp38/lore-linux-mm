Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B10B26B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 13:53:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c52so11537535wra.12
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 10:53:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v20si762646edi.164.2017.06.05.10.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Jun 2017 10:53:12 -0700 (PDT)
Date: Mon, 5 Jun 2017 13:52:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [6/6] mm: memcontrol: account slab stats per lruvec
Message-ID: <20170605175254.GA8547@cmpxchg.org>
References: <20170530181724.27197-7-hannes@cmpxchg.org>
 <20170605165203.GA20603@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605165203.GA20603@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jun 05, 2017 at 09:52:03AM -0700, Guenter Roeck wrote:
> On Tue, May 30, 2017 at 02:17:24PM -0400, Johannes Weiner wrote:
> > Josef's redesign of the balancing between slab caches and the page
> > cache requires slab cache statistics at the lruvec level.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> Presumably this is already known, but a remarkable number of crashes
> in next-20170605 bisects to this patch.

Thanks Guenter.

Can you test if the fix below resolves the problem?

---
