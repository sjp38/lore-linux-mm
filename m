Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2416B04C9
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 15:59:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n126so934671wma.7
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 12:59:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 28si1592056wrz.536.2018.01.05.12.59.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 12:59:05 -0800 (PST)
Date: Fri, 5 Jan 2018 21:59:03 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm:master 152/256] mm/migrate.c:1934:53: sparse: incorrect
 type in argument 2 (different argument counts)
Message-ID: <20180105205903.GV2801@dhcp22.suse.cz>
References: <201801051507.45CKDK0l%fengguang.wu@intel.com>
 <20180105124239.8d9c4e5631b8488807349f89@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105124239.8d9c4e5631b8488807349f89@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri 05-01-18 12:42:39, Andrew Morton wrote:
> On Fri, 5 Jan 2018 15:29:12 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > Hi Michal,
> > 
> > First bad commit (maybe != root cause):
> > 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   1ceb98996d2504dd4e0bcb5f4cb9009a18cd8aaa
> > commit: 37870392dd6966328ed2fe49a247ab37d6fa7344 [152/256] mm, hugetlb: unify core page allocation accounting and initialization
> > reproduce:
> >         # apt-get install sparse
> >         git checkout 37870392dd6966328ed2fe49a247ab37d6fa7344
> >         make ARCH=x86_64 allmodconfig
> >         make C=1 CF=-D__CHECK_ENDIAN__
> > 
> > 
> 
> --- a/mm/migrate.c~mm-migrate-remove-reason-argument-from-new_page_t-fix-fix
> +++ a/mm/migrate.c
> @@ -1784,8 +1784,7 @@ static bool migrate_balanced_pgdat(struc
>  }
>  
>  static struct page *alloc_misplaced_dst_page(struct page *page,
> -					   unsigned long data,
> -					   int **result)
> +					   unsigned long data)
>  {
>  	int nid = (int) data;
>  	struct page *newpage;
> _
> 
> That's against mm-migrate-remove-reason-argument-from-new_page_t.patch.

Yeah http://lkml.kernel.org/r/20180105090753.GI2801@dhcp22.suse.cz
and another that sneaked in http://lkml.kernel.org/r/20180105085259.GH2801@dhcp22.suse.cz

I really do not know how this passed my standard build test batery.
Something must have been clearly broken there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
