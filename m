Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 368DA6B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:52:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g6-v6so7503704lfg.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:52:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 198-v6sor523777lfa.82.2018.03.27.11.52.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 11:52:19 -0700 (PDT)
Date: Tue, 27 Mar 2018 21:52:17 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180327185217.GK2236@uranus>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180327062939.GV5652@dhcp22.suse.cz>
 <95a107ac-5e5b-92d7-dbde-2e961d85de28@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95a107ac-5e5b-92d7-dbde-2e961d85de28@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 27, 2018 at 02:38:11PM -0400, Yang Shi wrote:
> > Why do we need to hold mmap_sem here and call find_vma, when only
> > PR_SET_MM_ENV_END: is consuming it? I guess we can replace it wit the
> > new lock and take the mmap_sem only for PR_SET_MM_ENV_END.
> 
> Actually, I didn't think of why. It looks prctl_set_mm() checks if vma does
> exist when it tries to set stack_start, argv_* and env_*, btw not only
> env_end.
> 
> Cyrill may be able to give us some hint since C/R is the main user of this
> API.

First and most important it makes code smaller. This prctl call is really
rarely used. Of course we can optimize it, but as I said I would prefer
to simply deprecate this old interface (and I gonne to do so once time
permit).
