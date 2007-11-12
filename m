Date: Mon, 12 Nov 2007 11:07:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071111141609.GA6967@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711121106250.26682@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
 <20071109161455.GB32088@skynet.ie> <20071109164537.GG7507@us.ibm.com>
 <1194628732.5296.14.camel@localhost> <Pine.LNX.4.64.0711090924210.14572@schroedinger.engr.sgi.com>
 <20071111141609.GA6967@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 11 Nov 2007, Mel Gorman wrote:

> If MPOL_BIND is in effect, the allocation will be filtered based on the
> current allowed nodemask. If they specify THISNODE and the specified
> node or current node is not in the mask, I would expect the allocation
> to fail. Is that unexpected to anybody?

Currently GFP_THISNODE with MPOL_BIND results an allocation on the first 
node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
