Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F0B82600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:06:52 -0400 (EDT)
Date: Thu, 8 Apr 2010 19:06:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 08/14] Memory compaction core
Message-ID: <20100408170619.GP5749@random.random>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
 <1270224168-14775-9-git-send-email-mel@csn.ul.ie>
 <20100408165954.GI25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408165954.GI25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 05:59:54PM +0100, Mel Gorman wrote:
> On Fri, Apr 02, 2010 at 05:02:42PM +0100, Mel Gorman wrote:
> > This patch is the core of a mechanism which compacts memory in a zone by
> > relocating movable pages towards the end of the zone.
> > 
> 
> When merging compaction and transparent huge pages, Andrea spotted and
> fixed this problem in his tree but it should go to mmotm as well.
> 
> Thanks Andrea.

Thanks Mel for submitting this fix!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
