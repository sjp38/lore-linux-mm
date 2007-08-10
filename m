Date: Thu, 9 Aug 2007 18:44:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070809233300.GA31644@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708091843230.3185@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <20070809210716.14702.43074.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0708091431560.32324@schroedinger.engr.sgi.com>
 <20070809233300.GA31644@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007, Mel Gorman wrote:

> > > +#if defined(CONFIG_SMP) && INTERNODE_CACHE_SHIFT > ZONES_SHIFT
> > 
> > Is this necessary? ZONES_SHIFT is always <= 2 so it will work with 
> > any pointer. Why disable this for UP?
> > 
> 
> Caution in case the number of zones increases. There was no guarantee of
> zone alignment. It's the same reason I have a BUG_ON in the encode
> function so that if we don't catch problems at compile-time, it'll go
> BANG in a nice predictable fashion.

Caution would lead to a BUG_ON but why the #if? Why exclude UP?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
