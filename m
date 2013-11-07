Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id F38BE6B0158
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 08:25:11 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq13so589809pbb.6
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 05:25:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id hb3si3031205pac.65.2013.11.07.05.25.09
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 05:25:10 -0800 (PST)
Date: Thu, 7 Nov 2013 14:25:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-3.12 75/75] fs/proc/meminfo.c:undefined reference
 to `vm_commit_limit'
Message-ID: <20131107132505.GA16393@dhcp22.suse.cz>
References: <527b74a0.xBELNKuc6Ws8XONb%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <527b74a0.xBELNKuc6Ws8XONb%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, kbuild-all@01.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com

On Thu 07-11-13 19:08:16, Wu Fengguang wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.12
> head:   2f11d7af8df66cb4f217b6293ad8189aa101d601
> commit: 2f11d7af8df66cb4f217b6293ad8189aa101d601 [75/75] mm-factor-commit-limit-calculation-fix
> config: make ARCH=blackfin BF526-EZBRD_defconfig
> 
> All error/warnings:
> 
>    mm/built-in.o: In function `__vm_enough_memory':
>    (.text+0x11b4c): undefined reference to `vm_commit_limit'
>    fs/built-in.o: In function `meminfo_proc_show':
> >> fs/proc/meminfo.c:(.text+0x37ef0): undefined reference to `vm_commit_limit'

Andrew, it seems that moving vm_commit_limit out of mman.h is not that
easy because it breaks NOMMU configurations. mm/mmap.o is not part of
the nommu build apparently.

So either we move it back to mman.h or put it somewhere else. I do not
have a good idea where, though.

I have dropped mm-factor-commit-limit-calculation-fix from mm-git tree
for now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
