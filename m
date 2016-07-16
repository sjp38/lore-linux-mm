Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD386B025E
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 10:51:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so277226195pfb.0
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 07:51:45 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h5si4753996pfj.2.2016.07.16.07.51.43
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 07:51:44 -0700 (PDT)
Date: Sat, 16 Jul 2016 23:51:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: 4.1.28 is broken due to "mm/swap.c: flush lru pvecs on compound
 page arrival"
Message-ID: <20160716145142.GA29738@bbox>
References: <alpine.LRH.2.02.1607161037180.18821@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1607161037180.18821@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Ming Li <mingli199x@qq.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jul 16, 2016 at 10:46:17AM -0400, Mikulas Patocka wrote:
> Hi
> 
> The patch c5ad33184354260be6d05de57e46a5498692f6d6 on the kernel v4.1.28 
> breaks the kernel. The kernel crashes when executing the boot scripts with 
> "kernel panic: Out of memory and no killable processes...". The machine 
> has 512MB ram and 1 core.
> 
> Note that the upstream kernel 4.7-rc4 with this patch works, but when the 
> patch is backported to the 4.1 branch, it makes the system unbootable.

It seems a bug was introduced at backport time, I think.
Please, look at http://marc.info/?l=linux-mm&m=146868046305014&w=2

> 
> Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
