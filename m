Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 55C606B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:10:22 -0500 (EST)
Date: Wed, 28 Nov 2012 11:10:18 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/19] list: add a new LRU list type
Message-ID: <20121128161018.GA15089@infradead.org>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-7-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354058086-27937-7-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Wed, Nov 28, 2012 at 10:14:33AM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Several subsystems use the same construct for LRU lists - a list
> head, a spin lock and and item count. They also use exactly the same
> code for adding and removing items from the LRU. Create a generic
> type for these LRU lists.
> 
> This is the beginning of generic, node aware LRUs for shrinkers to
> work with.

Can you please add kerneldoc comments for the functions, and add
symbolic constants for the possible return values from the isolate
callback?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
