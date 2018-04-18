Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03E996B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 05:02:23 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m18-v6so354317lfj.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 02:02:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f69-v6sor179473lfe.37.2018.04.18.02.02.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 02:02:20 -0700 (PDT)
Date: Wed, 18 Apr 2018 12:02:17 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180418090217.GG19578@uranus.lan>
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418080555.GR17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418080555.GR17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 18, 2018 at 10:05:55AM +0200, Michal Hocko wrote:
> 
> Yes, looks good to me. As mentioned in other emails prctl_set_mm_map
> really deserves a comment explaining why we are doing the down_read
> 
> What about something like the following?
> "
> arg_lock protects concurent updates but we still need mmap_sem for read
> to exclude races with do_brk.
> "
> Acked-by: Michal Hocko <mhocko@suse.com>

Yes, thanks! Andrew, could you slightly update the changelog please?
