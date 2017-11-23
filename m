Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82FA56B026D
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 20:34:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d86so4346342pfk.19
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:34:05 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 3si8797276plt.771.2017.11.22.17.34.03
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 17:34:04 -0800 (PST)
Date: Thu, 23 Nov 2017 12:25:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/62] XArray November 2017 Edition
Message-ID: <20171123012501.GK4094@dastard>
References: <20171122210739.29916-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Nov 22, 2017 at 01:06:37PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I've lost count of the number of times I've posted the XArray before,
> so time for a new numbering scheme.  Here're two earlier versions,
> https://lkml.org/lkml/2017/3/17/724
> https://lwn.net/Articles/715948/ (this one's more loquacious in its
> description of things that are better about the radix tree API than the
> XArray).
> 
> This time around, I've gone for an approach of many small changes.
> Unfortunately, that means you get 62 moderate patches instead of dozens
> of big ones.

Where's the API documentation that tells things like constraints
about locking and lock-less lookups via RCU?

e.g. I notice in the XFS patches you seem to randomly strip out
rcu_read_lock/unlock() pairs that are currently around radix tree
lookup operations without explanation. Without documentation
describing how this stuff is supposed to work, review is somewhat
difficult...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
