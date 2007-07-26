Subject: Re: NUMA policy issues with ZONE_MOVABLE
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070726132336.GA18825@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
Content-Type: text/plain
Date: Thu, 26 Jul 2007 14:09:21 -0400
Message-Id: <1185473361.7653.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-26 at 14:23 +0100, Mel Gorman wrote:
> On (25/07/07 12:31), Christoph Lameter didst pronounce:
<snip>
> 
> > Lee should probably also review this in detail since he has recent 
> > experience fiddling around with memory policies. Paul has also 
> > experience in this area.
> > 
> 
> Lee had suggested almost the exact same solution but I'd like to hear if
> the implementation matches his expectation.
> 

Mel:

Your patch looks good to me.  I will add it to my test mix shortly.

Meanwhile, I see that Kame-san has posted an "idea patch" that I need to
review....

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
