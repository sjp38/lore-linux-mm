Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AEF7F680F81
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:12:27 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so330092999pac.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:12:27 -0800 (PST)
Date: Tue, 12 Jan 2016 12:11:28 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160112011128.GC6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
 <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Jan 11, 2016 at 05:07:23PM -0500, Benjamin LaHaise wrote:
> Enable a fully asynchronous fsync and fdatasync operations in aio using
> the aio thread queuing mechanism.
> 
> Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Insufficient. Needs the range to be passed through and call
vfs_fsync_range(), as I implemented here:

https://lkml.org/lkml/2015/10/28/878

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
