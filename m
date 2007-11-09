Date: Fri, 9 Nov 2007 10:22:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071109182059.GJ7507@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0711091021490.14929@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
 <20071109161455.GB32088@skynet.ie> <20071109164537.GG7507@us.ibm.com>
 <1194628732.5296.14.camel@localhost> <Pine.LNX.4.64.0711090924210.14572@schroedinger.engr.sgi.com>
 <20071109181607.GI7507@us.ibm.com> <20071109182059.GJ7507@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Nishanth Aravamudan wrote:

> > Indeed, this probably needs to be validated... Sigh, more interleaving
> > of policies and everything else...
> 
> Hrm, more importantly, isn't this an existing issue? Maybe should be
> resolved separately from the one zonelist patches.

GFP_THISNODE with alloc_pages() currently yields an allocation from the 
first node of the MPOL_BIND zonelist. So its the lowest node of the set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
