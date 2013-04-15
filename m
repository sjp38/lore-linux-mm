Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B43836B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 21:52:41 -0400 (EDT)
Message-ID: <1365990759.2359.30.camel@dabdike>
Subject: Re: [Lsf] [LSF/MM TOPIC] Beyond NUMA
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 14 Apr 2013 18:52:39 -0700
In-Reply-To: <20130414234934.GB5117@destitution>
References: <9f091f23-9314-422c-9f97-525ddefd483b@default>
	 <1365975590.2359.22.camel@dabdike> <20130414234934.GB5117@destitution>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Mon, 2013-04-15 at 09:49 +1000, Dave Chinner wrote:
> > I've got to say from a physics, rather than mm perspective, this sounds
> > to be a really badly framed problem.  We seek to eliminate complexity by
> > simplification.  What this often means is that even though the theory
> > allows us to solve a problem in an arbitrary frame, there's usually a
> > nice one where it looks a lot simpler (that's what the whole game of
> > eigenvector mathematics and group characters is all about).
> > 
> > Saying we need to consider remote in-use memory as high numa and manage
> > it from a local node looks a lot like saying we need to consider a
> > problem in an arbitrary frame rather than looking for the simplest one.
> > The fact of the matter is that network remote memory has latency orders
> > of magnitude above local ... the effect is so distinct, it's not even
> > worth calling it NUMA.  It does seem then that the correct frame to
> > consider this in is local + remote separately with a hierarchical
> > management (the massive difference in latencies makes this a simple
> > observation from perturbation theory).  Amazingly this is what current
> > clustering tools tend to do, so I don't really see there's much here to
> > add to the current practice.
> 
> Everyone who wants to talk about this topic should google "vNUMA"
> and read the research papers from a few years ago. It gives pretty
> good insight in the practicality of treating the RAM in a cluster as
> a single virtual NUMA machine with a large distance factor.

Um yes, insert comment about crazy Australians.  vNUMA was doomed to
failure from the beginning, I think, because they tried to maintain
coherency across the systems.  The paper contains a nicely understated
expression of disappointment that the resulting system was so slow.

I'm sure, as an ex-SGI person, you'd agree with me that high numa across
network is possible ... but only with a boatload of hardware
acceleration like the altix had.

> And then there's the crazy guys that have been trying to implement
> DLM (distributed large memory) using kernel based MPI communication
> for cache coherency protocols at page fault level....

I have to confess to being one of those crazy people way back when I was
at bell labs in the 90s ... it was mostly a curiosity until it found a
use in distributed databases.

But the question still stands: The current vogue for clustering is
locally managed resources coupled to a resource hierarchy to try and get
away from the entanglement factors that cause the problems that vNUMA
saw ... what I don't get from this topic is what it will add to the
current state of the art or more truthfully what I get is it seems to be
advocating going backwards ...

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
