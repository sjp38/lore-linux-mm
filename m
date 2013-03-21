Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E15FD6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 04:19:04 -0400 (EDT)
Date: Thu, 21 Mar 2013 09:19:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
Message-ID: <20130321081902.GD6094@dhcp22.suse.cz>
References: <20130320181957.GA1878@suse.de>
 <514A7163.5070700@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514A7163.5070700@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 21-03-13 10:33:07, Simon Jeons wrote:
> Hi Mel,
> On 03/21/2013 02:19 AM, Mel Gorman wrote:
> >The following problem was reported against a distribution kernel when
> >zone_reclaim was enabled but the same problem applies to the mainline
> >kernel. The reproduction case was as follows
> >
> >1. Run numactl -m +0 dd if=largefile of=/dev/null
> >    This allocates a large number of clean pages in node 0
> 
> I confuse why this need allocate a large number of clean pages?

It reads from file and puts pages into the page cache. The pages are not
modified so they are clean. Output file is /dev/null so no pages are
written. dd doesn't call fadvise(POSIX_FADV_DONTNEED) on the input file
by default so pages from the file stay in the page cache
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
