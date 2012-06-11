Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4E7A16B013F
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:41:38 -0400 (EDT)
Date: Mon, 11 Jun 2012 16:41:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: do not use page_count without a page pin
Message-ID: <20120611144132.GT3094@redhat.com>
References: <1339373872-31969-1-git-send-email-minchan@kernel.org>
 <4FD59C31.6000606@jp.fujitsu.com>
 <20120611074440.GI3094@redhat.com>
 <20120611133043.GA2340@barrios>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120611133043.GA2340@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

Hi Minchan,

On Mon, Jun 11, 2012 at 10:30:43PM +0900, Minchan Kim wrote:
> AFAIUC, you mean we have to increase reference count of head page?
> If so, it's not in __count_immobile_pages because it is already race-likely function
> so it shouldn't be critical although race happens.

I meant, shouldn't we take into account the full size? If it's in the
lru the whole thing can be moved away.

  if (!PageLRU(page)) {
     nr_pages = hpage_nr_pages(page);
     barrier();
     found += nr_pages;
     iter += nr_pages-1;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
