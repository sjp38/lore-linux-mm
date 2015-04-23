Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C5BED6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 05:23:34 -0400 (EDT)
Received: by widdi4 with SMTP id di4so85456703wid.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 02:23:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si12844774wjs.1.2015.04.23.02.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 02:23:33 -0700 (PDT)
Date: Thu, 23 Apr 2015 10:23:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/13] x86: mm: Enable deferred struct page
 initialisation on x86-64
Message-ID: <20150423092327.GJ14842@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
 <1429722473-28118-11-git-send-email-mgorman@suse.de>
 <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 22, 2015 at 04:45:00PM -0700, Andrew Morton wrote:
> On Wed, 22 Apr 2015 18:07:50 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -32,6 +32,7 @@ config X86
> >  	select HAVE_UNSTABLE_SCHED_CLOCK
> >  	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
> >  	select ARCH_SUPPORTS_INT128 if X86_64
> > +	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT if X86_64 && NUMA
> 
> Put this in the "config X86_64" section and skip the "X86_64 &&"?
> 

Done.

> Can we omit the whole defer_meminit= thing and permanently enable the
> feature?  That's simpler, provides better test coverage and is, we
> hope, faster.
> 

Yes. The intent was to have a workaround if there were any failures like
Waiman's vmalloc failures in an earlier version but they are bugs that
should be fixed.

> And can this be used on non-NUMA?  Presumably that won't speed things
> up any if we're bandwidth limited but again it's simpler and provides
> better coverage.

Nothing prevents it. There is less opportunity for parallelism but
improving coverage is desirable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
