Date: Thu, 13 Jan 2005 17:02:18 +0900 (JST)
Message-Id: <20050113.170218.77038944.taka@valinux.co.jp>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <Pine.LNX.4.58.0501122247390.18142@skynet>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB008C77C45@fmsmsx406.amr.corp.intel.com>
	<Pine.LNX.4.58.0501122247390.18142@skynet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mel@csn.ul.ie
Cc: matthew.e.tolentino@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

The global list looks interesting.

> > >Instead of having one global MAX_ORDER-sized array of free
> > >lists, there are
> > >three, one for each type of allocation. Finally, there is a
> > >list of pages of
> > >size 2^MAX_ORDER which is a global pool of the largest pages
> > >the kernel deals with.

> > is it so that the pages can
> > evolve according to system demands (assuming MAX_ORDER sized
> > chunks are eventually available again)?
> >
> 
> Exactly. Once a 2^MAX_ORDER block has been merged again, it will not be
> reserved until the next split.

FYI, MAX_ORDER is huge in some architectures.
I guess another watermark should be introduced instead of MAX_ORDER.

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
