Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 20:30:18 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160112013018.GE16499@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org> <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org> <20160112011128.GC6033@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112011128.GC6033@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jan 12, 2016 at 12:11:28PM +1100, Dave Chinner wrote:
> On Mon, Jan 11, 2016 at 05:07:23PM -0500, Benjamin LaHaise wrote:
> > Enable a fully asynchronous fsync and fdatasync operations in aio using
> > the aio thread queuing mechanism.
> > 
> > Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
> > Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> 
> Insufficient. Needs the range to be passed through and call
> vfs_fsync_range(), as I implemented here:

Noted.

> https://lkml.org/lkml/2015/10/28/878

Please at least Cc the aio list in the future on aio patches, as I do
not have the time to read linux-kernel these days unless prodded to do
so...

		-ben

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
