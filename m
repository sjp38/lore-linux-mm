Date: Thu, 12 Jun 2008 22:36:40 +0300
From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [RFC PATCH 2/2] Update defconfigs for CONFIG_HUGETLB
Message-ID: <20080612193638.GB17231@cs181133002.pp.htv.fi>
References: <1213296540.17108.8.camel@localhost.localdomain> <1213296945.17108.13.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1213296945.17108.13.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 12, 2008 at 02:55:45PM -0400, Adam Litke wrote:
> Update all defconfigs that specify a default configuration for hugetlbfs.
> There is now only one option: CONFIG_HUGETLB.  Replace the old
> CONFIG_HUGETLB_PAGE and CONFIG_HUGETLBFS options with the new one.  I found no
> cases where CONFIG_HUGETLBFS and CONFIG_HUGETLB_PAGE had different values so
> this patch is large but completely mechanical:
>...
>  335 files changed, 335 insertions(+), 385 deletions(-)
>...

Please don't do this kind of patches - it doesn't bring any advantage 
but can create tons of patch conflicts.

The next time a defconfig gets updated it will anyway automatically be 
fixed, and for defconfigs that aren't updated it doesn't create any 
problems to keep them as they are today until they might one day get 
updated.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
