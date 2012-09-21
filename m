Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 076856B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 19:32:29 -0400 (EDT)
Date: Fri, 21 Sep 2012 19:32:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/4] mm: remove unevictable_pgs_mlockfreed
Message-ID: <20120921233219.GY1560@cmpxchg.org>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
 <20120921124715.GD11157@csn.ul.ie>
 <alpine.LSU.2.00.1209211550180.23812@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209211550180.23812@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 21, 2012 at 03:56:11PM -0700, Hugh Dickins wrote:
> Simply remove UNEVICTABLE_MLOCKFREED and unevictable_pgs_mlockfreed
> line from /proc/vmstat: Johannes and Mel point out that it was very
> unlikely to have been used by any tool, and of course we can restore
> it easily enough if that turns out to be wrong.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Ying Han <yinghan@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
