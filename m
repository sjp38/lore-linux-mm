Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49EFA6B0011
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:06:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h16-v6so2812188lfg.13
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:06:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 141sor893026ljf.77.2018.04.10.13.06.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 13:06:52 -0700 (PDT)
Date: Tue, 10 Apr 2018 23:06:51 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180410200651.GF2041@uranus.lan>
References: <20180410090917.GZ21835@dhcp22.suse.cz>
 <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz>
 <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz>
 <20180410122804.GD2041@uranus.lan>
 <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
 <8c19f1fb-7baf-fef3-032d-4e93cfc63932@linux.alibaba.com>
 <20180410191742.GE2041@uranus.lan>
 <e868b50d-88a3-a649-d998-b7f2bb2c40aa@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e868b50d-88a3-a649-d998-b7f2bb2c40aa@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 10, 2018 at 12:33:35PM -0700, Yang Shi wrote:
...
> 
> The race condition is just valid when protecting start_brk, brk, start_data
> and end_data with the new lock, but keep using mmap_sem in brk path.
> 
> So, we should just need make a little tweak to have mmap_sem protect
> start_brk, brk, start_data and end_data, then have the new lock protect
> others so that we still can remove mmap_sem in proc as the patch is aimed to
> do.

+1. Sounds like a plan.
