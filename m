Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C13946B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 16:22:48 -0400 (EDT)
Date: Mon, 27 Aug 2012 17:22:32 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v9 0/5] make balloon pages movable by compaction
Message-ID: <20120827202231.GB6517@t510.redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
 <20120826075840.GE19551@redhat.com>
 <503A3565.2060004@redhat.com>
 <20120826154423.GA15478@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120826154423.GA15478@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sun, Aug 26, 2012 at 06:44:23PM +0300, Michael S. Tsirkin wrote:
> 
> I am simply asking how was this patchset tested.
> It would be nice to have this info in commit log.
> Since this is an optimization patch it is strange
> to see one with no numbers at all.
> For example, you probably run some workload and
> played with the balloon, and then saw less huge pages
> without the patch and more with?
> Please put this info in the cover letter.

Will do it, for sure. As soon as we get closer to an agreement on how the code
has to behave and looks like. I'll use Mel's mmtests bench suite for that.

Cheers!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
