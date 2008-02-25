Date: Mon, 25 Feb 2008 15:07:24 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: Page scan keeps touching kernel text pages
Message-ID: <20080225150724.GF2604@shadowen.org>
References: <20080224144710.GD31293@lazybastard.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080224144710.GD31293@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2008 at 03:47:11PM +0100, Jorn Engel wrote:
> While tracking down some unrelated bug I noticed that shrink_page_list()
> keeps testing very low page numbers (aka kernel text) until deciding
> that the page lacks a mapping and cannot get freed.  Looks like a waste
> of cpu and cachelines to me.
> 
> Is there a better reason for this behaviour than lack of a patch?

shrink_page_list() would be expected to be passed pages pulled from
the active or inactive lists via isolate_lru_pages()?  I would not have
expected to find the kernel text on the LRU and therefore not expect to
see it passed to shrink_page_list()?

I would expect to find pages below the kernel text as real pages, and
potentially on the LRU on some architectures.  Which architecture are
you seeing this?  Which zones do the pages belong?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
