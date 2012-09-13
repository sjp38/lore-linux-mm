Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 04B2F6B017E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 17:26:17 -0400 (EDT)
Date: Thu, 13 Sep 2012 22:26:13 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-ID: <20120913212613.GA11399@mudshark.cambridge.arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-4-git-send-email-will.deacon@arm.com>
 <20120913120514.135d2c38.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913120514.135d2c38.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Steve Capper <Steve.Capper@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

Hi Andrew,

On Thu, Sep 13, 2012 at 08:05:14PM +0100, Andrew Morton wrote:
> On Tue, 11 Sep 2012 17:47:16 +0100
> Will Deacon <will.deacon@arm.com> wrote:
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index d5c8019..3322342 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -318,7 +318,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> >  
> >  config TRANSPARENT_HUGEPAGE
> >  	bool "Transparent Hugepage Support"
> > -	depends on X86 && MMU
> > +	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
> >  	select COMPACTION
> >  	help
> >  	  Transparent Hugepages allows the kernel to use huge pages and
> 
> We need to talk with Gerald concerning
> http://ozlabs.org/~akpm/mmotm/broken-out/thp-x86-introduce-have_arch_transparent_hugepage.patch
> 
> 
> I did this.  Please check.

[...]

We missed Gerald's patch for s390 and, having picked it into our tree, it
acts as a drop-in replacement for what we came up with. So I think you
can just drop our patch ("mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE")
altogether.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
