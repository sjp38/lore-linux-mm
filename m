Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 075DD6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 15:11:36 -0400 (EDT)
Date: Tue, 14 Aug 2012 16:11:22 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC][PATCH -mm -v2 3/3] mm,vmscan: evict inactive file pages
 first
Message-ID: <20120814191122.GA11938@x61.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
 <20120808174904.5d241c38@cuia.bos.redhat.com>
 <20120812235616.GA9033@x61.redhat.com>
 <20120812221313.429db08b@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120812221313.429db08b@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On Sun, Aug 12, 2012 at 10:13:13PM -0400, Rik van Riel wrote:
> Oops.  Looks like I put it in the wrong spot in get_scan_count,
> the spot that is under the lru lock, which we really do not
> need for this code.
> 
> Can you try this one?

Thanks Rik, the lockup is now gone. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
