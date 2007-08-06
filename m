Date: Mon, 6 Aug 2007 14:56:08 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
Message-Id: <20070806145608.267bce88.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708021343420.10244@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie>
	<Pine.LNX.4.64.0708021343420.10244@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mel@skynet.ie, akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph wrote, responding to Mel and Andrew:
> > +static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
> > +{
> > +	return !zonelist->zlcache_ptr;
> > +}
> 
> I guess Paul needs to have a look at this one.

...

> > Which Paul?
> 
> Paul Jackson. 


I'll ack that the above snippet of code, alloc_should_filter_zonelist(),
does, as its comment explains, return true iff it's a custom zonelist such
as from MPOL_BIND.

As to the more interesting issues that this patch raises ... I have no clue.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
