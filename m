Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B66368D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:00:28 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Very aggressive memory reclaim
References: <AANLkTinFqqmE+fTMTLVU-_CwPE+LQv7CpXSQ5+CdAKLK@mail.gmail.com>
	<20110328215344.GC3008@dastard>
Date: Mon, 28 Mar 2011 16:58:50 -0700
In-Reply-To: <20110328215344.GC3008@dastard> (Dave Chinner's message of "Tue,
	29 Mar 2011 08:53:44 +1100")
Message-ID: <m2bp0u23wl.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: John Lepikhin <johnlepikhin@gmail.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

Dave Chinner <david@fromorbit.com> writes:
>
> First it would be useful to determine why the VM is reclaiming so
> much memory. If it is somewhat predictable when the excessive
> reclaim is going to happen, it might be worth capturing an event

Often it's to get pages of a higher order. Just tracing alloc_pages
should tell you that.

There are a few other cases (like memory failure handling), but they're
more obscure.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
