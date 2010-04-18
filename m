Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE066B01EF
	for <linux-mm@kvack.org>; Sat, 17 Apr 2010 20:15:22 -0400 (EDT)
Date: Sat, 17 Apr 2010 20:15:14 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100418001514.GA26575@infradead.org>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com> <1271118255-21070-2-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271118255-21070-2-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Any chance we can still get this into 2.6.34?  It's really needed to fix
a regression in XFS that would be hard to impossible to work around
inside the fs.  While it touches quite a few places the changes are
trivial and well understood.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
