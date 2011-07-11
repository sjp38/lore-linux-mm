Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A54156B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 05:57:13 -0400 (EDT)
Date: Mon, 11 Jul 2011 05:57:08 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/14] vmscan: add shrink_slab tracepoints
Message-ID: <20110711095708.GB19354@infradead.org>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
 <1310098486-6453-3-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310098486-6453-3-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 08, 2011 at 02:14:34PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> ??t is impossible to understand what the shrinkers are actually doing
> without instrumenting the code, so add a some tracepoints to allow
> insight to be gained.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

Looks good.  But wouldn't it be a good idea to give the shrinkers names
so that we can pretty print those in the trace event?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
