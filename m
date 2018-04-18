Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE7116B0006
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 05:03:18 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id i8-v6so724522plt.8
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 02:03:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9-v6si861372plb.415.2018.04.18.02.03.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 02:03:17 -0700 (PDT)
Date: Wed, 18 Apr 2018 11:03:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180418090314.GU17484@dhcp22.suse.cz>
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418080555.GR17484@dhcp22.suse.cz>
 <20180418090217.GG19578@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418090217.GG19578@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-04-18 12:02:17, Cyrill Gorcunov wrote:
> On Wed, Apr 18, 2018 at 10:05:55AM +0200, Michal Hocko wrote:
> > 
> > Yes, looks good to me. As mentioned in other emails prctl_set_mm_map
> > really deserves a comment explaining why we are doing the down_read
> > 
> > What about something like the following?
> > "
> > arg_lock protects concurent updates but we still need mmap_sem for read
> > to exclude races with do_brk.
> > "
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Yes, thanks! Andrew, could you slightly update the changelog please?

No, I meant it to be a comment in the _code_.

-- 
Michal Hocko
SUSE Labs
