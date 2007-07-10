Subject: Re: -mm merge plans -- anti-fragmentation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070710102043.GA20303@skynet.ie>
References: <20070710102043.GA20303@skynet.ie>
Content-Type: text/plain
Date: Tue, 10 Jul 2007 13:04:05 +0200
Message-Id: <1184065445.5281.16.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-10 at 11:20 +0100, Mel Gorman wrote:

<snip>

> > lumpy-reclaim-v4.patch
> 
> This patch is really what lumpy reclaim is. I believe Peter has looked
> at this and was happy enough at the time although he is cc'd here again
> in case this has changed. This is mainly useful with either grouping
> pages by mobility or the ZONE_MOVABLE stuff. However, at the time the
> patch was proposed, there was a feeling that it might help jumbo frame
> allocation on e1000's and maybe if fsblock optimistically uses
> contiguous pages it would have an application. I would like to see it go
> through to see does it help e1000 at least.

I'm not seeing how this will help e1000 (and other jumbo drivers). They
typically allocate using GFP_ATOMIC, so in order to satisfy those you'd
need to either have a higher order watermark or do atomic defrag of the
free space.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
