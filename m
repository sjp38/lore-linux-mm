Date: Tue, 22 May 2007 03:08:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070522010823.GC27743@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com> <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com> <20070520092552.GA7318@wotan.suse.de> <20070521080813.GQ31925@holomorphy.com> <20070521092742.GA19642@wotan.suse.de> <20070521224316.GC11166@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070521224316.GC11166@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 05:43:16PM -0500, Matt Mackall wrote:
> On Mon, May 21, 2007 at 11:27:42AM +0200, Nick Piggin wrote:
> > 
> > ... yeah, something like that would bypass 
> 
> As long as we're throwing out crazy unpopular ideas, try this one:
> 
> Divide struct page in two such that all the most commonly used
> elements are in one piece that's nicely sized and the rest are in
> another. Have two parallel arrays containing these pieces and accessor
> functions around the unpopular bits.
> 
> Whether a sensible divide between popular and unpopular bits isn't
> clear to me. But hey, I said it was crazy.

That would be unpopular with pagecache, because that uses pretty well
all fields.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
