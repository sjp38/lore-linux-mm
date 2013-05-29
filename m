Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id CFAE26B00A3
	for <linux-mm@kvack.org>; Wed, 29 May 2013 05:15:37 -0400 (EDT)
Date: Wed, 29 May 2013 10:15:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mmotm-2013-05-22: Bad page state
Message-ID: <20130529091530.GA29426@suse.de>
References: <51A526D9.3020803@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51A526D9.3020803@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>

On Tue, May 28, 2013 at 02:51:21PM -0700, Dave Hansen wrote:
> I was rebasing my mapping->radix_tree lock batching patches on top of
> Mel's stuff.  It looks like something is jumping the gun and freeing a
> page before it has been written out.  Somebody probably did an extra
> put_page() or something.
> 
> I'm running 3.10.0-rc2-mm1-00322-g8d4c612 from
> 
> 	git://git.cmpxchg.org/linux-mmotm.git
> 
> This is pretty reproducible.  I'll go try and test plain 3.10-rc2 next
> to make sure it's not coming from Linus's stuff.
> 

Patch 1 from the follow-up series "mm: vmscan: Block kswapd if it is
encountering pages under writeback -fix"

The rest of that follow-up series needs further work and I'm still
working on it but patch 1 is what fixes this particular problem.
Changelog says why.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
