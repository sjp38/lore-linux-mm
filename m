Date: Wed, 23 Jan 2008 13:14:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix boot problem in situations where the boot CPU is
 running on a memoryless node
In-Reply-To: <84144f020801231302g2cafdda9kf7f916121dc56aa5@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0801231312580.15681@schroedinger.engr.sgi.com>
References: <20080123075821.GA17713@aepfle.de>  <20080123121459.GA18631@aepfle.de>
 <20080123125236.GA18876@aepfle.de>  <20080123135513.GA14175@csn.ul.ie>
 <Pine.LNX.4.64.0801231611160.20050@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231626320.21475@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0801231648140.23343@sbz-30.cs.Helsinki.FI>
 <20080123155655.GB20156@csn.ul.ie>  <Pine.LNX.4.64.0801231906520.1028@sbz-30.cs.Helsinki.FI>
  <20080123195220.GB3848@us.ibm.com> <84144f020801231302g2cafdda9kf7f916121dc56aa5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Pekka Enberg wrote:

> I think Mel said that their configuration did work with 2.6.23
> although I also wonder how that's possible. AFAIK there has been some
> changes in the page allocator that might explain this. That is, if
> kmem_getpages() returned pages for memoryless node before, bootstrap
> would have worked.

Regular kmem_getpages is called with GFP_THISNODE set. There was some 
breakage in 2.6.22 and before with GFP_THISNODE returning pages from the 
wrong node if a node had no memory. So it may have worked accidentally and 
in an unsafe manner because the pages would have been associated with the 
wrong node which could trigger bug ons and locking troubles.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
