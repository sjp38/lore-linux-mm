Date: Sun, 28 Jan 2007 15:28:58 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128152858.GA23410@infradead.org>
References: <1169993494.10987.23.camel@lappy> <20070128144933.GD16552@infradead.org> <20070128151700.GA7644@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070128151700.GA7644@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 28, 2007 at 04:17:00PM +0100, Ingo Molnar wrote:
> scalability. I did lock profiling on the -rt kernel, which exposes such 
> things nicely. Half of the lock contention events during kernel compile 
> were due to kmap(). (The system had 2 GB of RAM, so 40% lowmem, 60% 
> highmem.)

Numbers please, and not on -rt but on mainline.  Please show the profiles.

> ps. please fix your mailer to not emit Mail-Followup-To headers. In Mutt
>     you can do this via "set followup_to=no" in your .muttrc.

I have told you last time that this is absolutely intentional and I won't
change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
