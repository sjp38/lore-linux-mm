Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07F506B00EF
	for <linux-mm@kvack.org>; Sat,  4 Jun 2011 10:08:57 -0400 (EDT)
Date: Sat, 4 Jun 2011 10:08:48 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/12] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20110604140848.GA20404@infradead.org>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
 <1306998067-27659-9-git-send-email-david@fromorbit.com>
 <20110604004231.GV11521@ZenIV.linux.org.uk>
 <20110604015212.GD561@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110604015212.GD561@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Sat, Jun 04, 2011 at 11:52:12AM +1000, Dave Chinner wrote:
> I wanted to put it early on in the unmount path so that the shrinker
> was guaranteed to be gone before evict_inodes() was called. That
> would mean that it is obviously safe to remove the iprune_sem
> serialisation in that function.

The iprune_sem removal is fine as soon as you have a per-sb shrinker
for the inodes which keeps an active reference on the superblock until
all the inodes are evicted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
