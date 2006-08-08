Date: Tue, 8 Aug 2006 08:50:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: linearly index zone->node_zonelists[]
In-Reply-To: <44D8818F.3080703@shadowen.org>
Message-ID: <Pine.LNX.4.64.0608080847150.27273@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
 <44D8818F.3080703@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Andy Whitcroft wrote:

> The GFP_foo flags are modifiers specifying some property we require from an
> allocation.  Currently all modifiers are singletons, that is they are all
> specified in isolation.  However, the code base as it stands does not enforce
> this.  I could see use cases where we might want to specify more than one
> flag.  For example a GFP_NODE_LOCAL flags which could be specified with any of
> the 'zone selectors'.  This would naturally work with the current
> implementation.

I have a patch here that implements such a thing its called 
__GFP_THISNODE but it does not use any of the bit mask features that I 
removed. __GFP_THISNODE simply checks if the allocation zone is local.

> Making the change you suggest here codifies the singleton status of these
> bits.  We should be sure we are not going to use this feature before its
> removed.  I am not sure I am comfortable saying there are no uses for it.

This certainly codifies the singleton status. However, I cannot imagine 
any uses for it that would not also require other significant changes in 
the page allocator. We can revisit that if someone comes up with a feature 
that needs this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
