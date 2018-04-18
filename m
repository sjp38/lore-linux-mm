Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF926B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 05:40:22 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s79-v6so373944lfg.20
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 02:40:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p23sor172564ljg.112.2018.04.18.02.40.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 02:40:21 -0700 (PDT)
Date: Wed, 18 Apr 2018 12:40:19 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180418094019.GH19578@uranus.lan>
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418080555.GR17484@dhcp22.suse.cz>
 <20180418090217.GG19578@uranus.lan>
 <20180418090314.GU17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418090314.GU17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 18, 2018 at 11:03:14AM +0200, Michal Hocko wrote:
> > > 
> > > What about something like the following?
> > > "
> > > arg_lock protects concurent updates but we still need mmap_sem for read
> > > to exclude races with do_brk.
> > > "
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Yes, thanks! Andrew, could you slightly update the changelog please?
> 
> No, I meant it to be a comment in the _code_.

Ah, I see. Then small patch on top should do the trick.
