Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CBC996B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 02:38:20 -0400 (EDT)
Date: Wed, 24 Aug 2011 02:38:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 09/13] inode: convert inode lru list to generic lru list
 code.
Message-ID: <20110824063817.GA6367@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-10-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-10-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

This silently drops the can_unuse check.  I can't say I was a fan of
it, but this really needs a separate patch with a proper description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
