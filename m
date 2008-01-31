Date: Wed, 30 Jan 2008 16:39:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 6/6] mm: bdi: allow setting a maximum for the bdi dirty
 limit
Message-Id: <20080130163927.760e94cc.akpm@linux-foundation.org>
In-Reply-To: <20080129154954.275142755@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
	<20080129154954.275142755@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 16:49:06 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Add "max_ratio" to /sys/class/bdi.  This indicates the maximum
> percentage of the global dirty threshold allocated to this bdi.

Maybe I'm having a stupid day, but I don't understand the semantics of this
min and max at all.  I've read the code, and I've read the comments (well,
I've hunted for some) and I've read the docs.

I really don't know how anyone could use this in its current state without
doing a lot of code-reading and complex experimentation.  All of which
would be unneeded if this tunable was properly documented.

So.  Please provide adequate documentation for this tunable.  I'd suggest
that it be pitched at the level of a reasonably competent system operator. 
It should help them understand why the tunable exists, why they might
choose to alter it, and what effects they can expect to see.  Hopefully a
reaonably competent kernel developer can then understand it too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
