Date: Fri, 22 Oct 2004 04:02:46 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] merge fs/hugetlb into mm/hugetlb.c
Message-ID: <20041022110246.GO17038@holomorphy.com>
References: <20041022104330.GA15769@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041022104330.GA15769@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2004 at 12:43:30PM +0200, Christoph Hellwig wrote:
> Having the common hugetlb code split over two files is rather confusing.
> Let's keep everything in a single file, ala tmpfs, and also remove the
> superflous HUGETLBFS that was implied by HUGETLB_PAGE.
> William, is the merged copyright statement okay?

The copyright looks fine. I guess this consolidation has no chance of
breaking arches, so it can't hurt.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
