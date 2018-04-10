Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE5516B0024
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:28:09 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g13-v6so2436699lfl.15
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:28:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor675283ljj.87.2018.04.10.05.28.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 05:28:08 -0700 (PDT)
Date: Tue, 10 Apr 2018 15:28:04 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180410122804.GD2041@uranus.lan>
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz>
 <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz>
 <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410111001.GD21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 10, 2018 at 01:10:01PM +0200, Michal Hocko wrote:
> > 
> > Because do_brk does vma manipulations, for this reason it's
> > running under down_write_killable(&mm->mmap_sem). Or you
> > mean something else?
> 
> Yes, all we need the new lock for is to get a consistent view on brk
> values. I am simply asking whether there is something fundamentally
> wrong by doing the update inside the new lock while keeping the original
> mmap_sem locking in the brk path. That would allow us to drop the
> mmap_sem lock in the proc path when looking at brk values.

Michal gimme some time. I guess  we might do so, but I need some
spare time to take more precise look into the code, hopefully today
evening. Also I've a suspicion that we've wracked check_data_rlimit
with this new lock in prctl. Need to verify it again.
