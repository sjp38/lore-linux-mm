Date: Mon, 25 Feb 2008 16:15:36 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: Page scan keeps touching kernel text pages
Message-ID: <20080225151536.GA13358@lazybastard.org>
References: <20080224144710.GD31293@lazybastard.org> <20080225150724.GF2604@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080225150724.GF2604@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 February 2008 15:07:24 +0000, Andy Whitcroft wrote:
> On Sun, Feb 24, 2008 at 03:47:11PM +0100, JA?rn Engel wrote:
> > While tracking down some unrelated bug I noticed that shrink_page_list()
> > keeps testing very low page numbers (aka kernel text) until deciding
> > that the page lacks a mapping and cannot get freed.  Looks like a waste
> > of cpu and cachelines to me.
> > 
> > Is there a better reason for this behaviour than lack of a patch?
> 
> shrink_page_list() would be expected to be passed pages pulled from
> the active or inactive lists via isolate_lru_pages()?  I would not have
> expected to find the kernel text on the LRU and therefore not expect to
> see it passed to shrink_page_list()?

Your expectations match mine.  At least someone shares my dilusions. :)

> I would expect to find pages below the kernel text as real pages, and
> potentially on the LRU on some architectures.  Which architecture are
> you seeing this?  Which zones do the pages belong?

32bit x86 (run in qemu, shouldn't make a difference).

Not sure about the zones.  Let me rerun to check that.

JA?rn

-- 
Ninety percent of everything is crap.
-- Sturgeon's Law

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
