Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 65BA19000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:03:07 -0400 (EDT)
Date: Wed, 28 Sep 2011 11:02:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2 v2] writeback: Add a 'reason' to wb_writeback_work
Message-ID: <20110928150242.GB16159@infradead.org>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313189245-7197-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Did we get to any conclusion on this series?  I think having these
additional reasons in the tracepoints and the additional statistics
would be extremely useful for us who have to deal with writeback
issues frequently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
