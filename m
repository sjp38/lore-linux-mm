Date: Fri, 22 Oct 2004 13:03:38 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] merge fs/hugetlb into mm/hugetlb.c
Message-ID: <20041022110338.GA16122@lst.de>
References: <20041022104330.GA15769@lst.de> <20041022035653.71565baa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041022035653.71565baa.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2004 at 03:56:53AM -0700, Andrew Morton wrote:
> Christoph Hellwig <hch@lst.de> wrote:
> >
> > 
> >  Having the common hugetlb code split over two files is rather confusing.
> >  Let's keep everything in a single file, ala tmpfs, and also remove the
> >  superflous HUGETLBFS that was implied by HUGETLB_PAGE.
> 
> Probably a sane change, but it would seriously screw over Chris Lameter. 
> Later?

the demand paging thing?  it'll need some more work first anyway.

>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
