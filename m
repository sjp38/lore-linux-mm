Date: Thu, 9 Aug 2007 14:27:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/4] Use one zonelist that is filtered instead of multiple
 zonelists
In-Reply-To: <20070809210656.14702.61074.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708091425340.32324@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <20070809210656.14702.61074.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some uses of the loops over online nodes that suppose memory is present on 
these nodes. These will have to be updated at some point to only loop over 
nodes with memory (memoryless nodes).

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
