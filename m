Date: Wed, 21 Jun 2006 10:16:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/14] Zoned VM counters V5
In-Reply-To: <44997D9E.8040304@google.com>
Message-ID: <Pine.LNX.4.64.0606211012590.20071@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <44997596.7050903@google.com> <Pine.LNX.4.64.0606211001370.19596@schroedinger.engr.sgi.com>
 <44997D9E.8040304@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: akpm@osdl.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Martin Bligh wrote:

> > Yes later patches also use the counters for other things. Please check out
> > the patch that uses these for numa counters etc.
> 
> OK, but looked like the original implementation was sort of tied to
> zones / the VM, at least in terminology, and code placement. I'll look
> at it again ...

Yes it is. This one is useful only for zone related information.

> > Also smaller counters help keep the pcp structure in one cacheline and
> > reduces the cache footprint. 
> 
> Sure, but for a normal sized system, the smaller the per-cpu portion,
> the more atomic ops you'll end up doing, surely?

So we now do two atomic ops for every 32 increments (threshold). If we 
increment the threshhold then we reduce the atomic overhead but this also 
influences the inaccurary of the global and per zone counter because 
there is the potential of more counter update deferrals. Keeping the 
threshold low makes the global and per zone counter more up to date.
I think 32 is a good compromise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
