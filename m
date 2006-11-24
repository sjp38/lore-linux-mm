Date: Fri, 24 Nov 2006 09:59:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/11] Add __GFP_MOVABLE flag and update callers
In-Reply-To: <Pine.LNX.4.64.0611230906110.27596@woody.osdl.org>
Message-ID: <Pine.LNX.4.64.0611240955170.24649@schroedinger.engr.sgi.com>
References: <20061121225022.11710.72178.sendpatchset@skynet.skynet.ie>
 <20061121225042.11710.15200.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211529030.32283@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211637120.3338@woody.osdl.org> <20061123163613.GA25818@skynet.ie>
 <Pine.LNX.4.64.0611230906110.27596@woody.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Nov 2006, Linus Torvalds wrote:

> And the assumption would be that if it's MOVABLE, then it's obviously a 
> USER allocation (it it can fail much more eagerly - that's really what the 
> whole USER bit ends up meaning internally).

We can probably make several types of kernel allocations movable if there 
would be some benefit from it.

Mel already has a problem with mlocked user pages in the movable section. 
If this is fixed by using page migration to move the mlocked pages then we 
can likely make addititional classes kernel pages also movable and reduce 
the amount of memory that is unmovable. If we have more movable pages then 
the defrag can work more efficiently. Having most pages movable will also 
help to make memory unplug a reality.

So please do not require movable pages to be user allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
