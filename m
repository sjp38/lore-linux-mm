Date: Wed, 26 Feb 2003 23:36:33 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] allow CONFIG_SWAP=n for i386
Message-ID: <20030226233632.A16845@infradead.org>
References: <20030227002104.D15352@sgi.com> <20030226150457.528bb284.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030226150457.528bb284.akpm@digeo.com>; from akpm@digeo.com on Wed, Feb 26, 2003 at 03:04:57PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 26, 2003 at 03:04:57PM -0800, Andrew Morton wrote:
> Christoph Hellwig <hch@sgi.com> wrote:
> >
> > There's a bunch of minor fixes needed to disable the swap
> > code for systems with mmu.
> 
> > +	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),
> 
> The ampersand needs to be removed.
> 
> Please at least compile-test stuff.  Actually checking that it runs appears
> to be optional lately anyway.

Well, it runs fine without CONFIG_SWAP, the box is up for two days now :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
