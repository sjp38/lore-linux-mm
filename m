Date: Fri, 22 Oct 2004 04:12:24 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] merge fs/hugetlb into mm/hugetlb.c
Message-Id: <20041022041224.79053e71.akpm@osdl.org>
In-Reply-To: <20041022110338.GA16122@lst.de>
References: <20041022104330.GA15769@lst.de>
	<20041022035653.71565baa.akpm@osdl.org>
	<20041022110338.GA16122@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Oct 22, 2004 at 03:56:53AM -0700, Andrew Morton wrote:
> > Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > 
> > >  Having the common hugetlb code split over two files is rather confusing.
> > >  Let's keep everything in a single file, ala tmpfs, and also remove the
> > >  superflous HUGETLBFS that was implied by HUGETLB_PAGE.
> > 
> > Probably a sane change, but it would seriously screw over Chris Lameter. 
> > Later?
> 
> the demand paging thing?  it'll need some more work first anyway.
> 

It'll need a shitload of work if we move all the files around when he's not
looking.

Later, please.   Yours is just a three-minute patch, no?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
