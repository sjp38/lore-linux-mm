Date: Wed, 15 Dec 2004 05:58:55 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041215045855.GH27225@wotan.suse.de>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50260000.1103061628@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Brent Casavant <bcasavan@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > And just to clarify, are you saying you want to see this before inclusion
> > in mainline kernels, or that it would be nice to have but not necessary?
> 
> I'd say it's a nice to have, rather than necessary, as long as it's not
> forced upon people. Maybe a config option that's on by default on ia64
> or something. Causing yourself TLB problems is much more acceptable than
> causing it for others ;-)

Given that Brent did lots of benchmarks which didn't show any slowdowns
I don't think this is really needed (at least as long as nobody
demonstrates a ireal slowdown from the patch). And having such special
cases is always ugly, better not have them when not needed.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
