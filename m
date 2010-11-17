Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 052EE8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:04:22 -0500 (EST)
Date: Wed, 17 Nov 2010 15:03:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
Message-Id: <20101117150330.139251f9.akpm@linux-foundation.org>
In-Reply-To: <20101117042720.033773013@intel.com>
References: <20101117042720.033773013@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 12:27:20 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%, and
> improves IO throughput from 38MB/s to 42MB/s.

The changes in CPU consumption are remarkable.  I've looked through the
changelogs but cannot find mention of where all that time was being
spent?


How well have these changes been tested with NFS?


The changes are complex and will probably do Bad Things for some
people.  Does the code implement sufficient
debug/reporting/instrumentation to enable you to diagnose, understand
and fix people's problems in the minimum possible time?  If not, please
add that stuff.  Just go nuts with it.  Put it in debugfs, add /*
DELETEME */ comments and we can pull it all out again in half a year or
so.

Or perhaps litter the code with temporary tracepoints, provided we can
come up with a way for our testers to trivially gather their output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
