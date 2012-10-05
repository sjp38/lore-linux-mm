Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CBADD6B0069
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 05:28:13 -0400 (EDT)
Date: Fri, 5 Oct 2012 11:28:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/8] THP support for Sparc64
Message-ID: <20121005092810.GA27763@dhcp22.suse.cz>
References: <20121002155544.2c67b1e8.akpm@linux-foundation.org>
 <20121003.220027.1636081487098835868.davem@davemloft.net>
 <20121004103548.GB6793@redhat.com>
 <20121004.141136.1763670567147718953.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121004.141136.1763670567147718953.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org, gerald.schaefer@de.ibm.com

On Thu 04-10-12 14:11:36, David Miller wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 4 Oct 2012 12:35:48 +0200
> 
> > Hi Dave,
> > 
> > On Wed, Oct 03, 2012 at 10:00:27PM -0400, David Miller wrote:
> >> From: Andrew Morton <akpm@linux-foundation.org>
> >> Date: Tue, 2 Oct 2012 15:55:44 -0700
> >> 
> >> > I had a shot at integrating all this onto the pending stuff in linux-next. 
> >> > "mm: Add and use update_mmu_cache_pmd() in transparent huge page code."
> >> > needed minor massaging in huge_memory.c.  But as Andrea mentioned, we
> >> > ran aground on Gerald's
> >> > http://ozlabs.org/~akpm/mmotm/broken-out/thp-remove-assumptions-on-pgtable_t-type.patch,
> >> > part of the thp-for-s390 work.
> >> 
> >> While working on a rebase relative to this work, I noticed that the
> >> s390 patches don't even compile.
> >> 
> >> It's because of that pmd_pgprot() change from Peter Z. which arrives
> >> asynchonously via the linux-next tree.  It makes THP start using
> >> pmd_pgprot() (a new interface) which the s390 patches don't provide.
> > 
> > My suggestion would be to ignore linux-next and port it to -mm only
> > and re-send to Andrew. schednuma is by mistake in linux-next, and
> > it's not going to get merged as far as I can tell.
> 
> Sorry Andrea, that simply is impractical.
> 
> The first thing Andrew's patch series does is include linux-next,
> therefore every THP and MM patch in his series is against linux-next.

FWIW there is also a pure -mm (non-rebased) git tree at
http://git.kernel.org/?p=linux/kernel/git/mhocko/mm.git;a=summary
since-3.6 branch. It is based on top of 3.6 with mm patches from
Andrew's tree.

HTH
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
