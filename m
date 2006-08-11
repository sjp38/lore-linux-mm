Date: Fri, 11 Aug 2006 12:16:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060811121540.2253cae7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608111216090.18564@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <20060810124137.6da0fdef.akpm@osdl.org> <Pine.LNX.4.64.0608102010150.12657@schroedinger.engr.sgi.com>
 <20060811110821.51096659.akpm@osdl.org> <Pine.LNX.4.64.0608111112000.18296@schroedinger.engr.sgi.com>
 <20060811114243.49fa4390.akpm@osdl.org> <Pine.LNX.4.64.0608111150550.18495@schroedinger.engr.sgi.com>
 <20060811121540.2253cae7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Aug 2006, Andrew Morton wrote:

> Perhaps there is a downside.  But one could argue that NUMA is a
> special-case.   Let's try it in a couple of places, see how it goes?

I'd be glad to use it for future patches. Its certainly useful to deal
with conditionals that are only relevant in NUMA situations.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
