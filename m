Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9217C6B0103
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 06:10:31 -0400 (EDT)
Date: Mon, 13 Sep 2010 11:10:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/17] writeback: remove the internal 5% low bound on
	dirty_ratio
Message-ID: <20100913101016.GF23508@csn.ul.ie>
References: <20100912154945.758129106@intel.com> <20100912155202.733389420@intel.com> <20100913095130.GD23508@csn.ul.ie> <20100913095708.GA31310@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100913095708.GA31310@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> > 
> > i.e. * instead of +. With +, the value for dirty is almost always going
> > to be simply 1%.
> 
> Where's the "+" come from?
> 

This is embarassing. I was reading mail on a small font that had reduced all *
to look like +. Ignore the question.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
