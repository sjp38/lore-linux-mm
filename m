Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 646B55F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 10:54:35 -0400 (EDT)
Date: Thu, 9 Apr 2009 16:57:46 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in the VM II
Message-ID: <20090409145746.GK14687@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org> <20090409075805.GG14687@one.firstfloor.org> <1239283829.23150.34.camel@think.oraclecorp.com> <20090409140257.GI14687@one.firstfloor.org> <1239287859.23150.57.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1239287859.23150.57.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

> Even though try_to_releasepage only checks page_writeback() the lower
> filesystems all bail on dirty pages or dirty buffers (see the checks
> done by try_to_free_buffers).
> 
> It looks like the only way we have to clean a page and all the buffers
> in it is the invalidatepage call.  But that doesn't return success or
> failure, so maybe invalidatepage followed by releasepage?

Ok. I'll poke at it more.

> 
> I'll have to read harder next week, the FS invalidatepage may expect
> truncate to be the only caller.

I have to be careful with locks; another lock would deadlock. Ok
I could drop the page lock temporarily, but that would be somewhat
risky of someone else coming in unexpectedly.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
