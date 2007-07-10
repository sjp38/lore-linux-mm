Date: Tue, 10 Jul 2007 11:46:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: -mm merge plans -- anti-fragmentation
In-Reply-To: <20070710130356.GG8779@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0707101142340.11906@schroedinger.engr.sgi.com>
References: <20070710102043.GA20303@skynet.ie> <20070710130356.GG8779@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Nick Piggin wrote:

> I realise in your pragmatic approach, you are encouraging users to
> put fallbacks in place in case a higher order page cannot be allocated,
> but I don't think either higher order pagecache or higher order slubs
> have such fallbacks (fsblock or a combination of fsblock and higher
> order pagecache could have, but...).

We have run mm kernels for month now without the need of a fallback. I 
purpose of ZONE_MOVABLE was to guarantee that higher order pages could be 
reclaimed and thus make the scheme reliable?

The experience so far shows that the approach works reliably. If there are 
issues then they need to be fixed. Putting in workarounds in other places 
such as in fsblock may just be hiding problems if there are any.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
