Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8C66B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:55:10 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so2897899ead.34
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:55:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si5474898eeo.109.2013.12.17.05.55.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:55:09 -0800 (PST)
Date: Tue, 17 Dec 2013 14:55:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
Message-ID: <20131217135506.GD26640@dhcp22.suse.cz>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
 <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com>
 <52AFC020.10403@ubuntukylin.com>
 <20131217035847.GA10392@parisc-linux.org>
 <52AFFBE3.8020507@ubuntukylin.com>
 <52B01594.80001@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B01594.80001@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Li Wang <liwang@ubuntukylin.com>, Matthew Wilcox <matthew@wil.cx>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

On Tue 17-12-13 17:12:52, Li Zefan wrote:
> On 2013/12/17 15:23, Li Wang wrote:
> > If we do wanna equip fadvise() with directory level page cache cleaning,
> > this could be solved by invoking (inode_permission() || capable(CAP_SYS_ADMIN)) before manipulating the page cache of that inode.
> > We think the current extension to 'drop_caches' has a complete back
> > compatibility, the old semantics keep unchanged, and with add-on
> > features to do finer granularity cache cleaning should be also
> > desirable.
> > 
> 
> I don't think you can extend the drop_caches interface this way. It should
> be used for debuging only.

Completely agreed. The interface shouldn't be further extended. I would
even argue it shouldn't be used in the first place.

> commit 9d0243bca345d5ce25d3f4b74b7facb3a6df1232
> Author: Andrew Morton <akpm@osdl.org>
> Date:   Sun Jan 8 01:00:39 2006 -0800
> 
>     [PATCH] drop-pagecache
> 
>     Add /proc/sys/vm/drop_caches.  When written to, this will cause the kernel to
>     discard as much pagecache and/or reclaimable slab objects as it can.  THis
>     operation requires root permissions.
> 
>     ...
> 
>     This is a debugging feature: useful for getting consistent results between
>     filesystem benchmarks.  We could possibly put it under a config option, but
>     it's less than 300 bytes.
> 
> Also see http://lkml.org/lkml/2013/7/26/230
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
