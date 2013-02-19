Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 128B86B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 06:30:16 -0500 (EST)
Date: Tue, 19 Feb 2013 11:30:12 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
Message-ID: <20130219113012.GP4365@suse.de>
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
 <20130218145018.GJ4365@suse.de>
 <5122E8C0.4020404@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5122E8C0.4020404@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 18, 2013 at 09:51:44PM -0500, KOSAKI Motohiro wrote:
> >> * Hugepage migration ? Currently, hugepage is not migratable and can?t
> >> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
> >> view.
> >>
> > 
> > migrate_huge_page() ?
> > 
> > It's also possible to allocate hugetlbfs pages in ZONE_MOVABLE but must
> > be enabled via /proc/sys/vm/hugepages_treat_as_movable.
> 
> Oops. I missed that. Sorry for noise.
> 
> But but... I wonder why this knob is disabled by default. I don't think anybody
> get a benefit form current default.
> 

It's disabled by default simply because at the time the pages were not
movable at all. They now should be movable with some additional work and
potentially the default could change after that or be removed entirely.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
