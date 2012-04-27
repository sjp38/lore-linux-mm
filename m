Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 09F9F6B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 06:28:59 -0400 (EDT)
Date: Fri, 27 Apr 2012 11:28:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 05/12] mm/vmscan: remove update_isolated_counts()
Message-ID: <20120427102855.GJ15299@suse.de>
References: <20120426075408.18961.80580.stgit@zurg>
 <20120426131743.9008.52231.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120426131743.9008.52231.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 26, 2012 at 05:17:43PM +0400, Konstantin Khlebnikov wrote:
> update_isolated_counts() no longer required, because lumpy-reclaim was removed.
> Insanity is over, now here only one kind of inactive pages.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

I should have spotted that. Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
