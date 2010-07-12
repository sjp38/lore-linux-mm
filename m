Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E12416B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 18:23:46 -0400 (EDT)
Date: Mon, 12 Jul 2010 15:22:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases
Message-Id: <20100712152254.2071ba5f.akpm@linux-foundation.org>
In-Reply-To: <20100712155239.GC30222@localhost>
References: <20100711020656.340075560@intel.com>
	<20100711021749.303817848@intel.com>
	<20100712020842.GC25335@dastard>
	<20100712155239.GC30222@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jul 2010 23:52:39 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > Also, I'd prefer that the
> > comments remain somewhat more descriptive of the circumstances that
> > we are operating under. Comments like "retry later to avoid blocking
> > writeback of other inodes" is far, far better than "retry later"
> > because it has "why" component that explains the reason for the
> > logic. You may remember why, but I sure won't in a few months time....

me2 (of course).  This code is waaaay too complex to be scrimping on comments.

> Ah yes the comment is too simple. However the redirty_tail() is not to
> avoid blocking writeback of other inodes, but to avoid eating 100% CPU
> on busy retrying a dirty inode/page that cannot perform writeback for
> a while. (In theory redirty_tail() can still busy retry though, when
> there is only one single dirty inode.) So how about
> 
>         /*
>          * somehow blocked: avoid busy retrying
>          */

That's much too short.  Expand on the "somehow" - provide an example,
describe the common/expected cause.  Fully explain what the "busy"
retry _is_ and how it can come about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
