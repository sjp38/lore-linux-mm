Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
	 <1179385718.27354.17.camel@twins>
	 <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 17 May 2007 19:52:15 +0200
Message-Id: <1179424335.2925.5.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-17 at 10:29 -0700, Christoph Lameter wrote:
> On Thu, 17 May 2007, Peter Zijlstra wrote:
> 
> > I'm really not seeing why you're making such a fuzz about it; normally
> > when you push the system this hard we're failing allocations left right
> > and center too. Its just that the block IO path has some mempools which
> > allow it to write out some (swap) pages and slowly get back to sanity.
> 
> I am weirdly confused by these patches. Among other things you told me 
> that the performance does not matter since its never (or rarely) being 
> used (why do it then?).

When we are very low on memory and do access the reserves by means of
ALLOC_NO_WATERMARKS, we want to avoid processed that are not entitled to
use such memory from running away with the little we have.

That is the whole and only point; restrict memory allocated under
ALLOC_NO_WATERMARKS to those processes that are entitled to it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
