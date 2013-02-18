Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 208A16B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 09:50:23 -0500 (EST)
Date: Mon, 18 Feb 2013 14:50:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
Message-ID: <20130218145018.GJ4365@suse.de>
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Feb 17, 2013 at 01:44:33AM -0500, KOSAKI Motohiro wrote:
> Sorry for the delay.
> 
> I would like to discuss the following topics:
> 
> 
> 
> * Hugepage migration ? Currently, hugepage is not migratable and can?t
> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
> view.
> 

migrate_huge_page() ?

It's also possible to allocate hugetlbfs pages in ZONE_MOVABLE but must
be enabled via /proc/sys/vm/hugepages_treat_as_movable.

> * Remove ZONE_MOVABLE ?Very long term goal. Maybe not suitable in this year.
> 

Whatever about removing it totally I would like to see node memory hot-remove
not depending on ZONE_MOVABLE.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
