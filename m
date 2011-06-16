Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 960C56B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 07:33:28 -0400 (EDT)
Date: Thu, 16 Jun 2011 07:33:21 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/12] Per superblock cache reclaim
Message-ID: <20110616113321.GA22422@infradead.org>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

Can we get some comments from the MM folks for patches 1-3?  Those look
like some pretty urgent fixes for really dumb shrinker behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
