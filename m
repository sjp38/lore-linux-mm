Date: Wed, 25 Feb 2004 11:12:19 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [RFC] Distributed mmap API
Message-ID: <20040225191219.GD1397@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <200402211400.16779.phillips@arcor.de> <20040222233911.GB1311@us.ibm.com> <200402251604.19040.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402251604.19040.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2004 at 04:04:19PM -0500, Daniel Phillips wrote:

Very cool!

> This is the function formerly known as invalidate_mmap_range, with the
> addition of a new code path in the zap_ call chain to handle MAP_PRIVATE
> properly.  This function by itself is enough to support a crude but useful
> form of distributed mmap where a shared file is cached only on one cluster
> node at a time.
> 
> To use this, the distributed filesystem has to hook do_no_page to intercept
> page faults and carry out the needed global locking.  The locking itself does
> not require any new kernel hooks.  In brief, the patch here and another patch
> to be presented for the do_no_page hook, together provide the core kernel API
> for a simplified, distributed mmap.  (Note that there may be a workaround for
> the lack of a do_no_page hook, but certainly not as simple and robust.)
> 
> To put this in perspective, I'll mention the two big limitations of the
> simplified API:
> 
>   1) Invalidation is always a whole file at a time

I must be missing something subtle here...  It looks to me like
the new unmap_mapping_range() API is capable of invalidating
portions of files, based on the "start" and "length" arguments.

What am I missing?

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
