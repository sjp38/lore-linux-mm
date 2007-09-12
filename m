Subject: Re: [PATCH 0/6] Use one zonelist per node instead of multiple
	zonelists v5 (resend)
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070911213006.23507.19569.sendpatchset@skynet.skynet.ie>
References: <20070911213006.23507.19569.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Wed, 12 Sep 2007 16:27:33 -0400
Message-Id: <1189628853.5004.66.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-11 at 22:30 +0100, Mel Gorman wrote:
> (Sorry for the resend, I mucked up the TO: line in the earlier sending)
> 
> This is the latest version of one-zonelist and it should be solid enough
> for wider testing. To briefly summarise, the patchset replaces multiple
> zonelists-per-node with one zonelist that is filtered based on nodemask and
> GFP flags. I've dropped the patch that replaces inline functions with macros
> from the end as it obscures the code for something that may or may not be a
> performance benefit on older compilers. If we see performance regressions that
> might have something to do with it, the patch is trivially to bring forward.
> 
> Andrew, please merge to -mm for wider testing and consideration for merging
> to mainline. Minimally, it gets rid of the hack in relation to ZONE_MOVABLE
> and MPOL_BIND.


Mel:

I'm just getting to this after sorting out an issue with the memory
controller stuff in 23-rc4-mm1.  I'm building all my kernels with the
memory controller enabled now, as it hits areas that I'm playing in.  I
wanted to give you a heads up that vmscan.c doesn't build with
CONTAINER_MEM_CONT configured with your patches.  I won't get to this
until tomorrow.  Since you're a few hours ahead of me, you might want to
take a look.  No worries, if you don't get a chance...

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
