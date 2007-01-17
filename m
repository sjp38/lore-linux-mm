Date: Tue, 16 Jan 2007 20:23:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/8] Convert higest_possible_node_id() into nr_node_ids
In-Reply-To: <200701171515.20380.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0701162023140.4849@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
 <200701170905.17234.ak@suse.de> <Pine.LNX.4.64.0701161913180.4677@schroedinger.engr.sgi.com>
 <200701171515.20380.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jan 2007, Andi Kleen wrote:

> > > Are you sure this is even possible in general on systems with node
> > > hotplug? The firmware might not pass a maximum limit.
> >
> > In that case the node possible map must include all nodes right?
> 
> Yes.

Then we are fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
