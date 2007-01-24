Subject: Re: [RFC] Limit the size of the pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45B7561C.9000102@yahoo.com.au>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <1169625333.4493.16.camel@taijtu>  <45B7561C.9000102@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 24 Jan 2007 13:58:08 +0100
Message-Id: <1169643488.6189.18.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-24 at 23:50 +1100, Nick Piggin wrote:
> Peter Zijlstra wrote:
> > On Tue, 2007-01-23 at 16:49 -0800, Christoph Lameter wrote:
> 
> >>2. Insure rapid turnaround of pages in the cache.
> 
> [...]
> 
> > The  only maybe valid point would be 2, and I'd like to see if we can't
> > solve that differently - a better use-once logic comes to mind.
> 
> There must be something I'm missing with that point. The faster
> the turnaround of pagecache pages, the *less* efficiently the
> pagecache is working (assuming a rapid turnaround means a high
> rate of pages brought into, then reclaimed from pagecache).
> 
> I can't argue that a smaller pagecache will be subject to a
> higher turnaround given the same workload, but I don't know why
> that would be a good thing.

I interpreted the issue as selecting the wrong pages for the 'working
set'. Like not quickly evicting pages from a large streaming read, which
then pushes out more useful pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
