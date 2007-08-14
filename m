Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0708140828060.27248@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <1187102203.6114.2.camel@twins>
	 <Pine.LNX.4.64.0708140828060.27248@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 14 Aug 2007 21:32:58 +0200
Message-Id: <1187119978.5337.1.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-14 at 08:29 -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Peter Zijlstra wrote:
> 
> > On Tue, 2007-08-14 at 07:21 -0700, Christoph Lameter wrote:
> > > The following patchset implements recursive reclaim. Recursive reclaim
> > > is necessary if we run out of memory in the writeout patch from reclaim.
> > > 
> > > This is f.e. important for stacked filesystems or anything that does
> > > complicated processing in the writeout path.
> > > 
> > > Recursive reclaim works because it limits itself to only reclaim pages
> > > that do not require writeout. It will only remove clean pages from the LRU.
> > > The dirty throttling of the VM during regular reclaim insures that the amount
> > > of dirty pages is limited. 
> > 
> > No it doesn't. All memory can be tied up by anonymous pages - who are
> > dirty by definition and are not clamped by the dirty limit.
> 
> Ok but that could be addressed by making sure that a certain portion of 
> memory is reserved for clean file backed pages.

Which gets us back to the initial problem of sizing this portion and
ensuring it is big enough to service the need.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
