Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6E95C6B00AC
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 09:01:49 -0500 (EST)
Date: Mon, 3 Jan 2011 08:58:15 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
Message-ID: <20110103135815.GA6024@thunk.org>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
 <AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
 <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, Jan 03, 2011 at 09:40:57AM +0200, Pekka Enberg wrote:
> I guess the rationale here is that if you're going to take the hit of
> memset() you can take the hit of unlikely() as well. We're optimizing
> for hot call-sites that allocate a small amount of memory and
> initialize everything themselves. That said, I don't think the
> unlikely() annotation matters much either way and am for removing it
> unless people object to that.

I suspect for many slab caches, all of the slab allocations for a
given slab cache type will have the GFP_ZERO flag passed.  So maybe it
would be more efficient to zap the entire page when it is pressed into
service for a particular slab cache, so we can avoid needing to use
memset on a per-object basis?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
